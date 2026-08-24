# frozen_string_literal: true

#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
# Author:: JJ Asghar (<jj@chef.io>)
# Author:: Lance Albertson (<lance@osuosl.org>)
#
# Copyright:: (C) 2013-2015, Jonathan Hartman
# Copyright:: (C) 2015-2020, Chef Software Inc.
# Copyright:: (C) 2026, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "fog/openstack"
require "yaml"
require "time" unless defined?(Time.now.iso8601)
require_relative "openstack_version"
require_relative "openstack/clouds"
require_relative "openstack/config"
require_relative "openstack/helpers"
require_relative "openstack/networking"
require_relative "openstack/server_helper"
require_relative "openstack/volume"

module Kitchen
  module Driver
    # Test Kitchen driver for OpenStack Nova.
    #
    # Creates and destroys Nova instances, optionally attaching floating IPs,
    # Cinder volumes and specific Neutron networks. Credentials come from
    # kitchen.yml, `OS_*` environment variables, or a standard
    # `clouds.yaml` -- see {Clouds} for the precedence rules.
    class Openstack < Kitchen::Driver::Base
      # Nova server states that mean the instance is up and reachable.
      #
      # @return [Array<String>]
      LIVE_STATES = %w{ACTIVE}.freeze

      # Settings Fog requires as Strings. Fog re-coerces anything that looks
      # numeric back to an Integer, so these are stringified on the way in.
      #
      # @return [Array<Symbol>]
      FOG_STRING_SETTINGS = %i{
        openstack_username
        openstack_api_key
        openstack_auth_url
        openstack_project_name
        openstack_project_id
        openstack_user_domain
        openstack_user_domain_id
        openstack_project_domain
        openstack_project_domain_id
        openstack_domain_id
        openstack_domain_name
        openstack_region
        openstack_endpoint_type
        openstack_identity_api_version
        openstack_application_credential_id
        openstack_application_credential_secret
        openstack_tenant
        openstack_tenant_id
      }.freeze

      include Clouds
      include Config
      include Helpers
      include Networking
      include ServerHelper

      kitchen_driver_api_version 2
      plugin_version Kitchen::Driver::OPENSTACK_VERSION

      default_config :openstack_cloud, nil
      default_config :clouds_yaml_path, nil
      default_config :server_name, nil

      default_config :server_name_prefix, nil
      default_config :key_name, nil
      default_config :port, "22"
      default_config :use_ipv6, false
      default_config :openstack_project_name, nil
      default_config :openstack_region, nil
      default_config :openstack_service_name, nil
      default_config :openstack_network_name, nil
      default_config :floating_ip_pool, nil
      default_config :allocate_floating_ip, false
      default_config :floating_ip, nil
      default_config :private_ip_order, 0
      default_config :public_ip_order, 0
      default_config :availability_zone, nil
      default_config :security_groups, nil
      default_config :network_ref, nil
      default_config :network_id, nil
      default_config :no_ssh_tcp_check, false
      default_config :no_ssh_tcp_check_sleep, 120
      default_config :glance_cache_wait_timeout, 600
      default_config :block_device_mapping, nil
      default_config :connect_timeout, 60
      default_config :read_timeout, 60
      default_config :write_timeout, 60
      default_config :metadata, nil

      # Merges clouds.yaml and `OS_*` values into the config hash.
      #
      # Done at finalize time rather than lazily so the resolved values show up
      # in `kitchen diagnose` and are available to every driver method.
      #
      # @param instance [Kitchen::Instance] the instance this driver serves
      # @return [self]
      def finalize_config!(instance)
        super
        apply_clouds_config
        self
      end

      # Creates a Nova instance and waits until it is reachable.
      #
      # Idempotent: returns immediately if `state` already names a server.
      #
      # @param state [Hash] mutable instance state; gains `:server_id` and
      #   `:hostname`
      # @return [void]
      # @raise [Kitchen::ActionFailed] on any Fog or Excon failure
      # @raise [Kitchen::InstanceFailure] if the server builds to ERROR state
      def create(state)
        config_server_name
        if state[:server_id]
          info "#{config[:server_name]} (#{state[:server_id]}) already exists."
          return
        end
        disable_ssl_validation if config[:disable_ssl_validation]
        server = create_server
        state[:server_id] = server.id

        # this is due to the glance_caching issues. Annoying yes, but necessary.
        debug "Waiting for a max time of:#{config[:glance_cache_wait_timeout]} seconds for OpenStack server to be in ACTIVE state"
        server.wait_for(config[:glance_cache_wait_timeout]) do
          sleep(1)
          if failed?
            raise(Kitchen::InstanceFailure,
              "OpenStack server ID <#{state[:server_id]}> build failed to ERROR state")
          end

          ready?
        end
        info "OpenStack server ID <#{state[:server_id]}> created"

        if config[:floating_ip]
          attach_ip(server, config[:floating_ip])
        elsif config[:floating_ip_pool]
          attach_ip_from_pool(server, config[:floating_ip_pool])
        end
        state[:hostname] = get_ip(server)
        wait_for_server(state)
        add_ohai_hint(state)
      rescue Fog::Errors::Error, Excon::Errors::Error => e
        raise ActionFailed, e.message
      end

      # Destroys the Nova instance named by `state`, releasing its floating IP
      # first when this driver allocated one.
      #
      # Safe to call when the server is already gone.
      #
      # @param state [Hash] mutable instance state; loses `:server_id` and
      #   `:hostname`
      # @return [void]
      def destroy(state)
        return if state[:server_id].nil?

        disable_ssl_validation if config[:disable_ssl_validation]
        server = compute.servers.get(state[:server_id])

        unless server.nil?
          if config[:floating_ip_pool] && config[:allocate_floating_ip]
            info "Retrieve the floating IP"
            pub, priv = get_public_private_ips(server)
            pub, = parse_ips(pub, priv)
            pub_ip = pub[config[:public_ip_order].to_i] || nil
            release_floating_ip(pub_ip) if pub_ip
          end
          server.destroy
        end
        info "OpenStack instance <#{state[:server_id]}> destroyed."
        state.delete(:server_id)
        state.delete(:hostname)
      end

      # Reports what Nova currently thinks of the server.
      #
      # @param state [Hash] instance state naming the server
      # @return [Hash] a Test Kitchen status hash, or the base implementation's
      #   answer when there is no server or Nova does not know it
      def status(state)
        return super unless state[:server_id]

        server = lookup_server(state[:server_id])
        return super unless server

        {
          live: LIVE_STATES.include?(server.state),
          state: server.state,
          source: "driver",
          resource_id: state[:server_id],
          message: "OpenStack reports the server as #{server.state}",
          checked_at: Time.now.utc.iso8601,
        }
      end

      private

      # Looks a server up without turning an unreachable cloud into a failure.
      #
      # @param server_id [String] the Nova server ID
      # @return [Fog::OpenStack::Compute::Server, nil] the server, or nil when
      #   Nova does not know it or cannot be reached
      def lookup_server(server_id)
        disable_ssl_validation if config[:disable_ssl_validation]
        compute.servers.get(server_id)
      rescue ::StandardError
        nil
      end

      # Releases a floating IP back to its pool.
      #
      # A floating IP that Neutron no longer knows about is not an error worth
      # failing a destroy over, so an unknown address is logged and skipped.
      #
      # @param pub_ip [String] the floating IP to release
      # @return [void]
      def release_floating_ip(pub_ip)
        info "Retrieve the ID of floating IP <#{pub_ip}>"
        net = network
        floating_ips = net.list_floating_ips(floating_ip_address: pub_ip).body["floatingips"]
        if floating_ips.nil? || floating_ips.empty?
          warn "No floating IP found matching <#{pub_ip}>; nothing to release."
          return
        end

        net.delete_floating_ip(floating_ips[0]["id"])
        info "OpenStack Floating IP <#{pub_ip}> released."
      end

      # Builds the settings hash handed to every Fog service constructor.
      #
      # @return [Hash] Fog connection settings
      def openstack_server
        server_def = {
          connection_options: {},
        }
        required_server_settings.each { |s| server_def[s] = normalize_fog_setting(s, config[s]) }
        optional_server_settings.each { |s| server_def[s] = normalize_fog_setting(s, config[s]) if config[s] }
        connection_options.each { |s| server_def[:connection_options][s] = config[s] if config[s] }
        server_def
      end

      # Settings always sent to Fog, even when nil.
      #
      # @return [Array<Symbol>]
      def required_server_settings
        %i{openstack_username openstack_api_key openstack_auth_url openstack_domain_id}
      end

      # Every other `openstack_*` setting Fog recognizes, sent only when set.
      #
      # @return [Array<Symbol>]
      def optional_server_settings
        Fog::OpenStack::Compute.recognized.select do |k|
          k.to_s.start_with?("openstack")
        end - required_server_settings
      end

      # Settings passed through to Excon rather than to Fog itself.
      #
      # `ssl_ca_file` belongs here, not in the Fog settings: Fog does not
      # recognize it, so a CA bundle from `OS_CACERT` or a clouds.yaml
      # `cacert` entry would otherwise be parsed and then silently dropped.
      #
      # @return [Array<Symbol>]
      def connection_options
        %i{read_timeout write_timeout connect_timeout ssl_ca_file}
      end

      # @return [Fog::OpenStack::Network] a Neutron connection
      def network
        Fog::OpenStack::Network.new(openstack_server)
      end

      # @return [Fog::OpenStack::Compute] a Nova connection
      def compute
        Fog::OpenStack::Compute.new(openstack_server)
      end

      # @return [Kitchen::Driver::Openstack::Volume] a Cinder helper
      def volume
        Volume.new(logger)
      end

      # Resolves the block device mapping to send to Nova.
      #
      # @param config [Hash] the driver config
      # @return [Hash] a Nova block device mapping
      def get_bdm(config)
        volume.get_bdm(config, openstack_server)
      end

      # Coerces one setting to the type Fog expects.
      #
      # @param setting [Symbol] the Fog config key
      # @param value [Object] the configured value
      # @return [Object] the coerced value
      def normalize_fog_setting(setting, value)
        return value if value.nil?
        return normalize_identity_api_version(value) if setting == :openstack_identity_api_version
        return value unless FOG_STRING_SETTINGS.include?(setting)

        value.to_s
      end

      # Normalizes the identity API version into a form Fog will not mangle.
      #
      # Fog::Service#coerce_options re-coerces any value where
      # `value.to_s.to_i.to_s == value.to_s` back to an Integer, which
      # then breaks Fog::OpenStack::Auth::Token.build (it calls `=~`
      # on the value). Prefixing with "v" keeps Fog from coercing and
      # still satisfies Token.build's `/(v)*2(\.0)*/i` regex check.
      #
      # @example
      #   normalize_identity_api_version(3)     #=> "v3"
      #   normalize_identity_api_version("2.0") #=> "v2.0"
      #
      # @param value [String, Integer] the configured identity API version
      # @return [String] a version string prefixed with "v"
      def normalize_identity_api_version(value)
        str = value.to_s.strip
        return str if str.empty?
        return str if str.start_with?("v", "V")

        case str
        when "2", "2.0" then "v2.0"
        else "v#{str}"
        end
      end
    end
  end
end
