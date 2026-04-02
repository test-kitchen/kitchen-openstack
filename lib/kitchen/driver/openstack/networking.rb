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

require 'ipaddr' unless defined?(IPAddr)

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Floating IP allocation and IP address resolution
      module Networking
        IP_POOL_LOCK = Mutex.new

        private

        def attach_ip_from_pool(server, pool)
          IP_POOL_LOCK.synchronize do
            info "Attaching floating IP from <#{pool}> pool"
            if config[:allocate_floating_ip]
              network_id = network
                           .list_networks(
                  name: pool
                ).body['networks'][0]['id']
              resp = network.create_floating_ip(network_id)
              ip = resp.body['floatingip']['floating_ip_address']
              info "Created floating IP <#{ip}> from <#{pool}> pool"
              config[:floating_ip] = ip
            else
              free_addrs = compute.addresses.map do |i|
                i.ip if i.fixed_ip.nil? && i.instance_id.nil? && i.pool == pool
              end.compact
              if free_addrs.empty?
                raise ActionFailed, "No available IPs in pool <#{pool}>"
              end

              config[:floating_ip] = free_addrs[0]
            end
            attach_ip(server, config[:floating_ip])
          end
        end

        def attach_ip(server, ip)
          info "Attaching floating IP <#{ip}>"
          server.associate_address ip
        end

        def get_public_private_ips(server)
          begin
            pub = server.public_ip_addresses
            priv = server.private_ip_addresses
          rescue Fog::OpenStack::Compute::NotFound, Excon::Errors::Forbidden
            # See Fog issue: https://github.com/fog/fog/issues/2160
            addrs = server.addresses
            addrs['public'] && pub = addrs['public'].map { |i| i['addr'] }
            addrs['private'] && priv = addrs['private'].map { |i| i['addr'] }
          end
          [pub, priv]
        end

        def get_ip(server)
          if config[:floating_ip]
            debug "Using floating ip: #{config[:floating_ip]}"
            return config[:floating_ip]
          end

          # make sure we have the latest info
          info 'Waiting for network information to be available...'
          begin
            w = server.wait_for { !addresses.empty? }
            debug "Waited #{w[:duration]} seconds for network information."
          rescue Fog::Errors::TimeoutError
            raise ActionFailed, 'Could not get network information (timed out)'
          end

          # should also work for private networks
          if config[:openstack_network_name]
            debug "Using configured net: #{config[:openstack_network_name]}"
            return filter_ips(server.addresses[config[:openstack_network_name]]).first['addr']
          end

          pub, priv = get_public_private_ips(server)
          priv = server.ip_addresses if Array(pub).empty? && Array(priv).empty?
          pub, priv = parse_ips(pub, priv)
          pub[config[:public_ip_order].to_i] ||
            priv[config[:private_ip_order].to_i] ||
            raise(ActionFailed, 'Could not find an IP')
        end

        def filter_ips(addresses)
          if config[:use_ipv6]
            addresses.select { |i| IPAddr.new(i['addr']).ipv6? }
          else
            addresses.select { |i| IPAddr.new(i['addr']).ipv4? }
          end
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
      end
    end
  end
end
