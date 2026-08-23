# frozen_string_literal: true

#
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

require "fog/openstack"
require "fog/openstack/compute/models/server"

# Factories for the Fog objects the driver talks to.
#
# Model objects (Server) get verifying doubles, so a Fog upgrade that renames
# `public_ip_addresses` fails the suite instead of silently passing.
#
# Service objects (Compute/Network/Volume) get plain doubles on purpose: Fog
# builds their `servers`/`images`/`list_networks` methods dynamically when the
# service is instantiated, so nothing is defined on the class for RSpec to
# verify against. There is no verifying double to be had here.
module FogDoubles
  # The `addresses` hash Nova returns for a server, in the shape the driver
  # actually parses.
  #
  # It is kept consistent with the default `public_ip_addresses` and
  # `private_ip_addresses` below: in fog-openstack those readers are derived
  # from this hash, so a server double with addresses populated one way and
  # empty the other describes a state no real cloud can produce.
  DEFAULT_ADDRESSES = {
    "public" => [{ "addr" => "1.2.3.4", "version" => 4, "OS-EXT-IPS:type" => "floating" }],
    "private" => [{ "addr" => "10.0.0.1", "version" => 4, "OS-EXT-IPS:type" => "fixed" }],
  }.freeze

  # A Fog compute server model.
  #
  # @param overrides [Hash] attributes to override on the default server
  # @return [InstanceDouble]
  def fog_server(**overrides)
    defaults = {
      id: "test123",
      name: "hello",
      public_ip_addresses: %w{1.2.3.4},
      private_ip_addresses: %w{10.0.0.1},
      addresses: DEFAULT_ADDRESSES,
      ip_addresses: [],
      associate_address: nil,
      destroy: true,
      ready?: true,
      failed?: false,
    }
    attrs = defaults.merge(overrides)
    canned_wait = attrs.delete(:wait_for)
    server = instance_double(Fog::OpenStack::Compute::Server, **attrs)

    if canned_wait
      allow(server).to receive(:wait_for).and_return(canned_wait)
    else
      stub_wait_for(server)
    end
    server
  end

  # Gives `server` a `wait_for` that follows Fog's contract.
  #
  # The block is evaluated in the server's own context and its result decides
  # the outcome: truthy means ready, and a block that never goes truthy raises
  # Fog::Errors::TimeoutError. Returning a canned `{ duration: 0 }` instead
  # meant no example ever executed `get_ip`'s `!addresses.empty?` predicate --
  # while SimpleCov still counted the line as covered.
  #
  # @param server [InstanceDouble] the server double to stub
  # @return [void]
  def stub_wait_for(server)
    # The block is instance_exec'd on the server, so a `sleep` inside it is a
    # call on the server and not on the driver -- the driver's own stubbed
    # sleep does not cover it, and the suite would wait on the wall clock.
    allow(server).to receive(:sleep).and_return(0)
    allow(server).to receive(:wait_for) do |_timeout, &blk|
      unless blk.nil? || server.instance_exec(&blk)
        raise Fog::Errors::TimeoutError, "The specified wait_for timeout was exceeded"
      end

      { duration: 0 }
    end
  end

  # A named, identified resource as returned by an images/flavors/networks
  # collection. `find_matching` only ever reads #id and #name.
  #
  # @param id [String] resource id
  # @param name [String, nil] resource name
  # @return [RSpec::Mocks::Double]
  def fog_resource(id:, name: nil)
    double("Fog resource #{id}", id: id, name: name)
  end

  # A stand-in Fog compute service. See the note above on why this is not a
  # verifying double.
  #
  # @param overrides [Hash] collections to expose
  # @return [RSpec::Mocks::Double]
  def fog_compute(**overrides)
    double("Fog::OpenStack::Compute", **{ servers: [], images: [], flavors: [], addresses: [] }.merge(overrides))
  end

  # A stand-in Fog network service.
  #
  # @param overrides [Hash] requests/collections to expose
  # @return [RSpec::Mocks::Double]
  def fog_network(**overrides)
    double("Fog::OpenStack::Network", **overrides)
  end

  # Wraps a body hash the way Fog's request layer returns it.
  #
  # @param body [Hash] the parsed response body
  # @return [RSpec::Mocks::Double] an object responding to #body
  def fog_response(body)
    double("Excon::Response", body: body)
  end

  # A floating address entry from `compute.addresses`.
  #
  # @param ip [String] the floating IP
  # @param pool [String] the pool it belongs to
  # @param fixed_ip [String, nil] set when the address is already in use
  # @param instance_id [String, nil] set when the address is already attached
  # @return [RSpec::Mocks::Double]
  def fog_address(ip:, pool:, fixed_ip: nil, instance_id: nil)
    double("Fog address #{ip}", ip: ip, pool: pool, fixed_ip: fixed_ip, instance_id: instance_id)
  end
end

RSpec.configure { |config| config.include FogDoubles }
