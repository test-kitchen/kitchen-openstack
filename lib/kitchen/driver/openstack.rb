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
require 'socket'

module Kitchen
  module Driver
    # Openstack driver for Kitchen.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Openstack < Kitchen::Driver::SSHBase
      default_config :name, nil
      default_config :public_key_path, File.expand_path('~/.ssh/id_dsa.pub')
      default_config :username, 'root'
      default_config :port, '22'
      default_config :openstack_region, nil

      def create(state)
        config[:name] ||= generate_name(instance.name)
        config[:disable_ssl_validation] and disable_ssl_validation
        server = create_server
        state[:server_id] = server.id
        info("OpenStack instance <#{state[:server_id]}> created.")
        server.wait_for { print '.'; ready? } ; puts "\n(server ready)"
        state[:hostname] = get_ip(server)
        # As a consequence of IP weirdness, the OpenStack setup() method is
        # also borked
        wait_for_sshd(state[:hostname]) ; puts '(ssh ready)'
        config[:key_name] or do_ssh_setup(state, config, server)
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        config[:disable_ssl_validation] and disable_ssl_validation
        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("OpenStack instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def compute
        server_def = {
          :provider           => 'OpenStack',
          :openstack_username => config[:openstack_username],
          :openstack_api_key  => config[:openstack_api_key],
          :openstack_auth_url => config[:openstack_auth_url],
          :openstack_tenant   => config[:openstack_tenant]
        }
        if config[:openstack_region]
          server_def[:openstack_region] = config[:openstack_region]
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
        compute.servers.create(server_def)
      end

      def generate_name(base)
        # Generate what should be a unique server name
        rand_str = Array.new(8) { rand(36).to_s(36) }.join
        "#{base}-#{Etc.getlogin}-#{Socket.gethostname}-#{rand_str}"
      end

      def get_ip(server)
        if server.addresses['public'] and !server.addresses['public'].empty?
          # server.public_ip_address stopped working in Fog 1.10.0
          return server.addresses['public'].first['addr']
        else
          return server.addresses['private'].first['addr']
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
