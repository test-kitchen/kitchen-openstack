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

require "ipaddr" unless defined?(IPAddr)

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Floating IP allocation and IP address resolution
      module Networking
        # Serializes floating IP selection across the driver instances that
        # Test Kitchen runs in parallel. Without it, two concurrent converges
        # can pick the same free address out of the pool and one of them fails
        # to associate it.
        #
        # @return [Mutex]
        IP_POOL_LOCK = Mutex.new

        private

        # Attaches a floating IP from the named pool to the server, allocating
        # a fresh one first when `:allocate_floating_ip` is set.
        #
        # Held under {IP_POOL_LOCK} for the whole select-then-attach sequence,
        # so a concurrent converge cannot claim the same address in between.
        #
        # @param server [Fog::OpenStack::Compute::Server] the server to attach to
        # @param pool [String] name of the floating IP pool / external network
        # @return [void]
        # @raise [Kitchen::ActionFailed] if the pool does not exist, or holds no
        #   free addresses
        def attach_ip_from_pool(server, pool)
          IP_POOL_LOCK.synchronize do
            info "Attaching floating IP from <#{pool}> pool"
            config[:floating_ip] = if config[:allocate_floating_ip]
                                     allocate_ip_from_pool(pool)
                                   else
                                     free_ip_from_pool(pool)
                                   end
            attach_ip(server, config[:floating_ip])
          end
        end

        # Asks Neutron for a brand new floating IP on the named external
        # network.
        #
        # @param pool [String] name of the external network
        # @return [String] the newly allocated floating IP
        # @raise [Kitchen::ActionFailed] if no network matches `pool`
        def allocate_ip_from_pool(pool)
          net = network
          networks = net.list_networks(name: pool).body["networks"]
          if networks.nil? || networks.empty?
            raise ActionFailed, "Floating IP pool <#{pool}> not found"
          end

          resp = net.create_floating_ip(networks[0]["id"])
          ip = resp.body["floatingip"]["floating_ip_address"]
          info "Created floating IP <#{ip}> from <#{pool}> pool"
          ip
        end

        # Picks an already-allocated but unattached floating IP out of the pool.
        #
        # @param pool [String] name of the floating IP pool
        # @return [String] a free floating IP
        # @raise [Kitchen::ActionFailed] if every address in the pool is in use
        def free_ip_from_pool(pool)
          # `find`, not `map`+`compact`: this runs while holding IP_POOL_LOCK,
          # which serializes parallel converges, so it should stop at the first
          # usable address rather than building a throwaway list of all of them.
          free = compute.addresses.find do |i|
            i.fixed_ip.nil? && i.instance_id.nil? && i.pool == pool
          end
          raise ActionFailed, "No available IPs in pool <#{pool}>" if free.nil?

          free.ip
        end

        # Associates a floating IP with a server.
        #
        # @param server [Fog::OpenStack::Compute::Server] the server
        # @param ip [String] the floating IP to attach
        # @return [void]
        def attach_ip(server, ip)
          info "Attaching floating IP <#{ip}>"
          server.associate_address ip
        end

        # Reads the server's public and private addresses.
        #
        # Deployments without the floating IP extension answer the dedicated
        # accessors with 404/403, so fall back to picking the lists out of the
        # generic addresses hash.
        #
        # @see https://github.com/fog/fog/issues/2160
        # @param server [Fog::OpenStack::Compute::Server] the server
        # @return [Array(Array<String>, Array<String>)] public and private
        #   addresses, either of which may be nil
        def get_public_private_ips(server)
          begin
            pub = server.public_ip_addresses
            priv = server.private_ip_addresses
          rescue Fog::OpenStack::Compute::NotFound, Excon::Errors::Forbidden
            addrs = server.addresses
            addrs["public"] && pub = addrs["public"].map { |i| i["addr"] }
            addrs["private"] && priv = addrs["private"].map { |i| i["addr"] }
          end
          [pub, priv]
        end

        # Determines the address Test Kitchen should connect to.
        #
        # Resolution order:
        #
        # 1. an explicitly configured `:floating_ip`
        # 2. the first address on `:openstack_network_name`, if configured
        # 3. `:public_ip_order` into the public addresses
        # 4. `:private_ip_order` into the private addresses
        #
        # @param server [Fog::OpenStack::Compute::Server] the server
        # @return [String] the address to connect to
        # @raise [Kitchen::ActionFailed] if network information never arrives,
        #   or no address of the requested family can be found
        def get_ip(server)
          if config[:floating_ip]
            debug "Using floating ip: #{config[:floating_ip]}"
            return config[:floating_ip]
          end

          # make sure we have the latest info
          info "Waiting for network information to be available..."
          begin
            w = server.wait_for { !addresses.empty? }
            debug "Waited #{w[:duration]} seconds for network information."
          rescue Fog::Errors::TimeoutError
            raise ActionFailed, "Could not get network information (timed out)"
          end

          return ip_from_named_network(server) if config[:openstack_network_name]

          pub, priv = get_public_private_ips(server)
          priv = server.ip_addresses if Array(pub).empty? && Array(priv).empty?
          pub, priv = parse_ips(pub, priv)
          pub[config[:public_ip_order].to_i] ||
            priv[config[:private_ip_order].to_i] ||
            raise(ActionFailed, "Could not find an IP")
        end

        # Picks the first usable address off the network named by
        # `:openstack_network_name`.
        #
        # @param server [Fog::OpenStack::Compute::Server] the server
        # @return [String] the address
        # @raise [Kitchen::ActionFailed] if the server is not on that network,
        #   or has no address there of the configured IP family
        def ip_from_named_network(server)
          name = config[:openstack_network_name]
          debug "Using configured net: #{name}"

          addresses = server.addresses[name]
          raise ActionFailed, "Server is not attached to network <#{name}>" if addresses.nil?

          matching = filter_ips(addresses)
          if matching.empty?
            raise ActionFailed,
              "No #{config[:use_ipv6] ? "IPv6" : "IPv4"} address found on network <#{name}>"
          end

          matching.first["addr"]
        end

        # Keeps only the addresses matching the configured IP family.
        #
        # @param addresses [Array<Hash>] address hashes, each with an `"addr"` key
        # @return [Array<Hash>] the matching subset
        def filter_ips(addresses)
          if config[:use_ipv6]
            addresses.select { |i| IPAddr.new(i["addr"]).ipv6? }
          else
            addresses.select { |i| IPAddr.new(i["addr"]).ipv4? }
          end
        end

        # Normalizes and filters public/private address lists to the configured
        # IP family.
        #
        # @param pub [Array<String>, String, nil] public addresses
        # @param priv [Array<String>, String, nil] private addresses
        # @return [Array(Array<String>, Array<String>)] filtered public and
        #   private address lists
        def parse_ips(pub, priv)
          # `select`, not `select!`: Array(x) returns x itself when x is already
          # an Array, so filtering in place would edit the caller's list -- and
          # the caller's list here is the Fog server model's own address data.
          wanted = config[:use_ipv6] ? :ipv6? : :ipv4?
          [Array(pub), Array(priv)].map do |addrs|
            addrs.select { |i| IPAddr.new(i).public_send(wanted) }
          end
        end
      end
    end
  end
end
