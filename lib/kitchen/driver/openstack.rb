# -*- encoding: utf-8 -*-
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013, Jonathan Hartman
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

module Kitchen
  module Driver
    # Openstack driver for Kitchen.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Openstack < Kitchen::Driver::SSHBase
      def self.key_path
        files = ['id_rsa', 'id_dsa']
        files.each { |file|
          path = File.expand_path("~/.ssh/#{file}")
          if File.exists?(path)
            return path
          end
        }
        File.expand_path('~/.ssh/id_dsa')
      end

      default_config :name, nil
      default_config :private_key_path, self.key_path()
      default_config :public_key_path, self.key_path()+'.pub'
      default_config :username, 'root'
      default_config :port, '22'
      default_config :use_ipv6, false
      default_config :openstack_tenant, nil
      default_config :openstack_region, nil
      default_config :openstack_service_name, nil
      default_config :openstack_network_name, nil

      def create(state)
        config[:name] ||= generate_name(instance.name)
        config[:disable_ssl_validation] and disable_ssl_validation
        server = create_server
        state[:server_id] = server.id
        info "OpenStack instance <#{state[:server_id]}> created."
        server.wait_for { print '.'; ready? } ; puts "\n(server ready)"
        attach_ip(server) if config[:floating_ip_pool]
        state[:hostname] = get_ip(server)
        wait_for_sshd(state[:hostname]) ; puts '(ssh ready)'
        unless config[:ssh_key] or config[:key_name]
          key_exists = false
          for i in 0..10
            key_exists = check_ssh_key(state, config, server, i<10)
            break if key_exists
            sleep 1
          end
          if not key_exists
            do_ssh_setup(state, config, server)
          end
        end
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        config[:disable_ssl_validation] and disable_ssl_validation
        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info "OpenStack instance <#{state[:server_id]}> destroyed."
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def compute
        server_def = {
          :provider           => 'OpenStack',
          :openstack_username => config[:openstack_username],
          :openstack_api_key  => config[:openstack_api_key],
          :openstack_auth_url => config[:openstack_auth_url]
        }
        optional = [
          :openstack_tenant, :openstack_region, :openstack_service_name
        ]
        optional.each do |o|
          config[o] and server_def[o] = config[o]
        end
        Fog::Compute.new(server_def)
      end

      def create_server
        server_def = {
          :name => config[:name],
          :image_ref => config[:image_ref],
          :flavor_ref => config[:flavor_ref]
        }
        if config[:public_key_path]
          server_def[:public_key_path] = config[:public_key_path]
        end
        server_def[:key_name] = config[:key_name] if config[:key_name]
        # Can't use the Fog bootstrap and/or setup methods here; they require a
        # public IP address that can't be guaranteed to exist across all
        # OpenStack deployments (e.g. TryStack ARM only has private IPs).
        compute.servers.create(server_def)
      end

      def generate_name(base)
        # Generate what should be a unique server name
        sep = '-'
        pieces = [
          base,
          Etc.getlogin,
          Socket.gethostname,
          Array.new(8) { rand(36).to_s(36) }.join
        ]
        until pieces.join(sep).length <= 64 do
          if pieces[2].length > 24
            pieces[2] = pieces[2][0..-2]
          elsif pieces[1].length > 16
            pieces[1] = pieces[1][0..-2]
          elsif pieces[0].length > 16
            pieces[0] = pieces[0][0..-2]
          end
        end
        pieces.join sep
      end

      def attach_ip(server)
        pool_name = config[:floating_ip_pool]
        ips = compute.addresses.all
        free_addresses = ips.delete_if {|p| p.pool!=pool_name || p.instance_id}
        ip = nil
        while free_addresses.count > 0 and ip.nil?
          # try to claim an ip
          begin
            server.associate_address(free_addresses[0].ip)
            ip = free_addresses[0]
            puts "Reusing existing ip #{ip.ip}"
          rescue
            free_addresses.shift
          end
        end
        server.addresses['public']=[{
          "raw"=>ip, "version"=>4,
          "ip"=>ip.ip, "addr"=>ip.ip
        }]
      end

      def get_ip(server)
        if config[:openstack_network_name]
          debug "Using configured network: #{config[:openstack_network_name]}"
          return server.addresses[config[:openstack_network_name]].first['addr']
        end
        begin
          pub, priv = server.public_ip_addresses, server.private_ip_addresses
        rescue Fog::Compute::OpenStack::NotFound
          # See Fog issue: https://github.com/fog/fog/issues/2160
          addrs = server.addresses
          addrs['public'] and pub = addrs['public'].map { |i| i['addr'] }
          addrs['private'] and priv = addrs['private'].map { |i| i['addr'] }
        end
        pub, priv = parse_ips(pub, priv)
        pub.first || priv.first || raise(ActionFailed, 'Could not find an IP')
      end

      def parse_ips(pub, priv)
        pub, priv = Array(pub), Array(priv)
        if config[:use_ipv6]
          [pub, priv].each { |n| n.select! { |i| IPAddr.new(i).ipv6? } }
        else
          [pub, priv].each { |n| n.select! { |i| IPAddr.new(i).ipv4? } }
        end
        return pub, priv
      end

      def check_ssh_key(state, config, server, ignore_errors)
        opts = {}
        if server.password
          opts[:password] = server.password
        end
        if File.exists?(config[:private_key_path])
          opts = { :key_data => open(config[:private_key_path]).read }
        end
        ssh = Fog::SSH.new(state[:hostname], config[:username], opts)
        begin
          ssh.run('true')
          return true
        rescue
          if not ignore_errors
            raise
          end
          return false
        end
      end

      def do_ssh_setup(state, config, server)
        ssh = Fog::SSH.new(state[:hostname], config[:username],
          { :password => server.password })
        pub_key = open(config[:public_key_path]).read
        ssh.run([
          %{mkdir .ssh},
          %{echo "#{pub_key}" >> ~/.ssh/authorized_keys},
          %{passwd -l #{config[:username]}}
        ])
      end

      def disable_ssl_validation
        require 'excon'
        Excon.defaults[:ssl_verify_peer] = false
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
