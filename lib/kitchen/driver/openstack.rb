# Encoding: UTF-8
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013-2015, Jonathan Hartman
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

require 'benchmark'
require 'fog'
require 'kitchen'
require 'etc'
require 'ipaddr'
require 'socket'
require 'ohai'
require_relative 'openstack/volume'

module Kitchen
  module Driver
    # Openstack driver for Kitchen.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Openstack < Kitchen::Driver::Base
      @@ip_pool_lock = Mutex.new

      default_config :server_name, nil
      default_config :server_name_prefix, nil
      default_config :key_name, nil
      if :private_key_path
        default_config :private_key_path do
          %w(id_rsa id_dsa).map do |k|
            f = File.expand_path "~/.ssh/#{k}"
            f if File.exist?(f)
          end.compact.first
        end
      else
        puts "You don't have a [:public_key_path] set."
        puts "You'll need to add it otherwise this'll break."
        exit 1
      end
      default_config :public_key_path do |driver|
        driver[:private_key_path] + '.pub'
      end
      default_config :username, 'root'
      default_config :password, nil
      default_config :port, '22'
      default_config :use_ipv6, false
      default_config :openstack_tenant, nil
      default_config :openstack_region, nil
      default_config :openstack_service_name, nil
      default_config :openstack_network_name, nil
      default_config :floating_ip_pool, nil
      default_config :floating_ip, nil
      default_config :availability_zone, nil
      default_config :security_groups, nil
      default_config :network_ref, nil

      # TODO: no idea how to map this
      # to new transport in test kitchen 1.4,
      # figure it out
      default_config :no_ssh_tcp_check, false
      default_config :no_ssh_tcp_check_sleep, 120

      default_config :block_device_mapping, nil

      # Taken from kitchen-ec2
      def self.deprecation_warn(driver, old_key, new_key)
        driver.warn "WARN: The driver[#{driver.class.name}] config key " \
         "`#{old_key}` is deprecated, please use `#{new_key}`"
      end

      validations[:username] = lambda do |attr, val, driver|
        deprecation_warn(driver, attr, 'transport.username') unless val.nil?
      end

      validations[:password] = lambda do |attr, val, driver|
        deprecation_warn(driver, attr, 'transport.password') unless val.nil?
      end

      validations[:port] = lambda do |attr, val, driver|
        deprecation_warn(driver, attr, 'transport.port') unless val.nil?
      end

      validations[:private_key_path] = lambda do |attr, val, driver|
        deprecation_warn(driver, attr, 'transport.ssh_key') unless val.nil?
      end

      # Lifted from https://github.com/test-kitchen/kitchen-ec2
      # This copies transport config from the current config object into the
      # state.  This relies on logic in the transport that merges the transport
      # config with the current state object, so its a bad coupling.  But we
      # can get rid of this when we get rid of these deprecated configs!
      def copy_deprecated_configs(state)
        state[:username] = config[:username] if config[:username]
        state[:ssh_key] = config[:private_key_path] if config[:private_key_path]
        state[:port] = config[:port] if config[:port]
        state[:password] = config[:password] if config[:password]
      end

      def create(state)
        set_server_name
        config[:disable_ssl_validation] && disable_ssl_validation
        server = create_server
        state[:server_id] = server.id
        info "OpenStack instance <#{state[:server_id]}> created."
        server.wait_for do
          print '.'
          ready?
        end
        info "\n(server ready)"
        if config[:floating_ip]
          attach_ip(server, config[:floating_ip])
        elsif config[:floating_ip_pool]
          attach_ip_from_pool(server, config[:floating_ip_pool])
        end
        state[:hostname] = get_ip(server)
        instance.transport.connection(state).wait_until_ready
        add_ohai_hint(state)
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        config[:disable_ssl_validation] && disable_ssl_validation
        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info "OpenStack instance <#{state[:server_id]}> destroyed."
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def openstack_server
        server_def = {
          provider: 'OpenStack'
        }
        required_server_settings.each { |s| server_def[s] = config[s] }
        optional_server_settings.each { |s| server_def[s] = config[s] }
        server_def
      end

      def set_server_name
        return if config[:server_name]
        if config[:server_name_prefix]
          config[:server_name] = server_name_prefix(
            config[:server_name_prefix]
          )
        else
          config[:server_name] = default_name
        end
      end

      def required_server_settings
        [:openstack_username, :openstack_api_key, :openstack_auth_url]
      end

      def optional_server_settings
        [:openstack_tenant, :openstack_region, :openstack_service_name]
      end

      def network
        Fog::Network.new(openstack_server)
      end

      def compute
        Fog::Compute.new(openstack_server)
      end

      def volume
        Volume.new
      end

      def get_bdm(config)
        volume.get_bdm(config, openstack_server)
      end

      def create_server
        server_def = init_configuration

        if config[:network_ref]
          networks = [].concat([config[:network_ref]])
          server_def[:nics] = networks.flatten.map do |net|
            { 'net_id' => find_network(net).id }
          end
        end

        if config[:block_device_mapping]
          server_def[:block_device_mapping] = get_bdm(config)
        end

        [
          :security_groups,
          :public_key_path,
          :key_name,
          :user_data
        ].each do |c|
          server_def[c] = optional_config(c) if config[c]
        end

        # Can't use the Fog bootstrap and/or setup methods here; they require a
        # public IP address that can't be guaranteed to exist across all
        # OpenStack deployments (e.g. TryStack ARM only has private IPs).
        compute.servers.create(server_def)
      end

      def init_configuration
        {
          name: config[:server_name],
          image_ref: find_image(config[:image_ref]).id,
          flavor_ref: find_flavor(config[:flavor_ref]).id,
          availability_zone: config[:availability_zone]
        }
      end

      def optional_config(c)
        case c
        when :security_groups
          config[c] if config[c].is_a?(Array)
        when :user_data
          File.open(config[c]) { |f| f.read } if File.exist?(config[c])
        else
          config[c]
        end
      end

      def find_image(image_ref)
        image = find_matching(compute.images, image_ref)
        fail(ActionFailed, 'Image not found') unless image
        debug "Selected image: #{image.id} #{image.name}"
        image
      end

      def find_flavor(flavor_ref)
        flavor = find_matching(compute.flavors, flavor_ref)
        fail(ActionFailed, 'Flavor not found') unless flavor
        debug "Selected flavor: #{flavor.id} #{flavor.name}"
        flavor
      end

      def find_network(network_ref)
        net = find_matching(network.networks.all, network_ref)
        fail(ActionFailed, 'Network not found') unless net
        debug "Selected net: #{net.id} #{net.name}"
        net
      end

      # Generate what should be a unique server name up to 63 total chars
      # Base name:    15
      # Username:     15
      # Hostname:     23
      # Random string: 7
      # Separators:    3
      # ================
      # Total:        63
      def default_name
        [
          instance.name.gsub(/\W/, '')[0..14],
          (Etc.getlogin || 'nologin').gsub(/\W/, '')[0..14],
          Socket.gethostname.gsub(/\W/, '')[0..22],
          Array.new(7) { rand(36).to_s(36) }.join
        ].join('-')
      end

      def server_name_prefix(server_name_prefix)
        # Generate what should be a unique server name with given prefix
        # of up to 63 total chars
        #
        # Provided prefix:  variable, max 54
        # Separator:        1
        # Random string:    8
        # ===================
        # Max:              63
        #
        if server_name_prefix.length > 54
          warn 'Server name prefix too long, truncated to 54 characters'
          server_name_prefix = server_name_prefix[0..53]
        end

        server_name_prefix.gsub!(/\W/, '')

        if server_name_prefix.empty?
          warn 'Server name prefix empty or invalid; using fully generated name'
          default_name
        else
          random_suffix = ('a'..'z').to_a.sample(8).join
          server_name_prefix + '-' + random_suffix
        end
      end

      def attach_ip_from_pool(server, pool)
        @@ip_pool_lock.synchronize do
          info "Attaching floating IP from <#{pool}> pool"
          free_addrs = compute.addresses.map do |i|
            i.ip if i.fixed_ip.nil? && i.instance_id.nil? && i.pool == pool
          end.compact
          if free_addrs.empty?
            fail ActionFailed, "No available IPs in pool <#{pool}>"
          end
          config[:floating_ip] = free_addrs[0]
          attach_ip(server, free_addrs[0])
        end
      end

      def attach_ip(server, ip)
        info "Attaching floating IP <#{ip}>"
        server.associate_address ip
        (server.addresses['public'] ||= []) << { 'version' => 4, 'addr' => ip }
      end

      def get_public_private_ips(server)
        begin
          pub = server.public_ip_addresses
          priv = server.private_ip_addresses
        rescue Fog::Compute::OpenStack::NotFound, Excon::Errors::Forbidden
          # See Fog issue: https://github.com/fog/fog/issues/2160
          addrs = server.addresses
          addrs['public'] && pub = addrs['public'].map { |i| i['addr'] }
          addrs['private'] && priv = addrs['private'].map { |i| i['addr'] }
        end
        [pub, priv]
      end

      def get_ip(server)
        unless config[:floating_ip].nil?
          debug "Using floating ip: #{config[:floating_ip]}"
          return config[:floating_ip]
        end
        if config[:openstack_network_name]
          debug "Using configured net: #{config[:openstack_network_name]}"
          return server.addresses[config[:openstack_network_name]].first['addr']
        end
        pub, priv = get_public_private_ips(server)
        priv ||= server.ip_addresses unless pub
        pub, priv = parse_ips(pub, priv)
        pub.first || priv.first || fail(ActionFailed, 'Could not find an IP')
      end

      def parse_ips(pub, priv)
        pub = Array(pub)
        priv = Array(priv)
        if config[:use_ipv6]
          [pub, priv].each { |n| n.select! { |i| IPAddr.new(i).ipv6? } }
        else
          [pub, priv].each { |n| n.select! { |i| IPAddr.new(i).ipv4? } }
        end
        [pub, priv]
      end

      def add_ohai_hint(state)
        info 'Adding OpenStack hint for ohai'
        mkdir_cmd = "sudo mkdir -p #{Ohai::Config[:hints_path][0]}"
        touch_cmd = "sudo touch #{Ohai::Config[:hints_path][0]}/openstack.json"

        instance.transport.connection(state).execute(
          "#{mkdir_cmd};#{touch_cmd}"
        )
      end

      def disable_ssl_validation
        require 'excon'
        Excon.defaults[:ssl_verify_peer] = false
      end

      def find_matching(collection, name)
        name = name.to_s
        if name.start_with?('/') && name.end_with?('/')
          regex = Regexp.new(name[1...-1])
          # check for regex name match
          collection.each { |single| return single if regex =~ single.name }
        else
          # check for exact id match
          collection.each { |single| return single if single.id == name }
          # check for exact name match
          collection.each { |single| return single if single.name == name }
        end
        nil
      end
    end
  end
end
