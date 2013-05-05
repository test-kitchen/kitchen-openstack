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
      default_config :name,             nil
      default_config :public_key_path,  File.expand_path('~/.ssh/id_dsa.pub')
      default_config :username,         'root'
      default_config :port,             '22'

      def create(state)
        if not config[:name]
          # Generate what should be a unique server name
          config[:name] = "#{instance.name}-#{Etc.getlogin}-" +
            "#{Socket.gethostname}-#{Array.new(8){rand(36).to_s(36)}.join}"
        end
        if config[:disable_ssl_validation]
          require 'excon'
          Excon.defaults[:ssl_verify_peer] = false
        end
        server = create_server
        state[:server_id] = server.id
        info("OpenStack instance <#{state[:server_id]}> created.")
        server.wait_for { print '.'; ready? } ; puts "\n(server ready)"
        if server.addresses['public'] and !server.addresses['public'].empty?
          # server.public_ip_address stopped working in Fog 1.10.0
          state[:hostname] = server.addresses['public'].first['addr']
        else
          state[:hostname] = server.addresses['private'].first['addr']
        end
        # As a consequence of IP weirdness, the OpenStack setup() method is
        # also borked
        wait_for_sshd(state[:hostname]) ; puts '(ssh ready)'
        if !config[:key_name]
          ssh = Fog::SSH.new(state[:hostname], config[:username],
                             {:password => server.password})
          pub_key = open(config[:public_key_path]).read
          ssh.run([
                   %{mkdir .ssh},
                   %{echo "#{pub_key}" >> ~/.ssh/authorized_keys},
                   %{passwd -l #{config[:username]}}
                  ])
        end
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("OpenStack instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def compute
        Fog::Compute.new(
                         :provider           => 'OpenStack',
                         :openstack_username => config[:openstack_username],
                         :openstack_api_key  => config[:openstack_api_key],
                         :openstack_auth_url => config[:openstack_auth_url],
                         :openstack_tenant   => config[:openstack_tenant]
                         )
      end

      def create_server
        server_def = { :name => config[:name], :image_ref => config[:image_ref], :flavor_ref => config[:flavor_ref]}
        server_def[:public_key_path] = config[:public_key_path] if config[:public_key_path]
        server_def[:key_name] = config[:key_name] if config[:key_name]
        compute.servers.create(server_def)
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
