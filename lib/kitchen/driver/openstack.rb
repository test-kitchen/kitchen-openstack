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
require_relative "openstack_version"
require_relative "openstack/config"
require_relative "openstack/helpers"
require_relative "openstack/networking"
require_relative "openstack/server_helper"
require_relative "openstack/volume"

module Kitchen
  module Driver
    # This takes from the Base Class and creates the OpenStack driver.
    class Openstack < Kitchen::Driver::Base
      include Config
      include Helpers
      include Networking
      include ServerHelper

      kitchen_driver_api_version 2
      plugin_version Kitchen::Driver::OPENSTACK_VERSION

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
          raise(Kitchen::InstanceFailure, "OpenStack server ID <#{state[:server_id]}> build failed to ERROR state") if failed?

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
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

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
            if pub_ip
              info "Retrieve the ID of floating IP <#{pub_ip}>"
              floating_ip_id = network.list_floating_ips(floating_ip_address: pub_ip).body["floatingips"][0]["id"]
              network.delete_floating_ip(floating_ip_id)
              info "OpenStack Floating IP <#{pub_ip}> released."
            end
          end
          server.destroy
        end
        info "OpenStack instance <#{state[:server_id]}> destroyed."
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def openstack_server
        server_def = {
          connection_options: {},
        }
        required_server_settings.each { |s| server_def[s] = config[s] }
        optional_server_settings.each { |s| server_def[s] = config[s] if config[s] }
        connection_options.each { |s| server_def[:connection_options][s] = config[s] if config[s] }
        server_def
      end

      def required_server_settings
        %i{openstack_username openstack_api_key openstack_auth_url openstack_domain_id}
      end

      def optional_server_settings
        Fog::OpenStack::Compute.recognized.select do |k|
          k.to_s.start_with?("openstack")
        end - required_server_settings
      end

      def connection_options
        %i{read_timeout write_timeout connect_timeout}
      end

      def network
        Fog::OpenStack::Network.new(openstack_server)
      end

      def compute
        Fog::OpenStack::Compute.new(openstack_server)
      end

      def volume
        Volume.new(logger)
      end

      def get_bdm(config)
        volume.get_bdm(config, openstack_server)
      end
    end
  end
end
