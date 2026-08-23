# frozen_string_literal: true

RSpec.describe Kitchen::Driver::Openstack::Networking do
  include_context "with a configured driver"

  let(:server) { fog_server }

  describe "#attach_ip_from_pool" do
    context "when reusing an already-allocated address" do
      let(:config) { { floating_ip_pool: "swimmers" } }

      let(:addresses) do
        [
          fog_address(ip: "1.1.1.1", pool: "swimmers", instance_id: "already-used"),
          fog_address(ip: "1.1.1.2", pool: "some-other-pool"),
          fog_address(ip: "1.1.1.3", pool: "swimmers", fixed_ip: "10.0.0.5"),
          fog_address(ip: "1.1.1.4", pool: "swimmers"),
          fog_address(ip: "1.1.1.5", pool: "swimmers"),
        ]
      end

      before { allow(driver).to receive(:compute).and_return(fog_compute(addresses: addresses)) }

      it "attaches the first genuinely free address in the pool" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(server).to have_received(:associate_address).with("1.1.1.4")
      end

      it "records the chosen address in config" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(driver[:floating_ip]).to eq("1.1.1.4")
      end

      it "does not allocate a new address" do
        expect(driver).not_to receive(:network)

        driver.send(:attach_ip_from_pool, server, "swimmers")
      end

      context "when every address in the pool is taken" do
        let(:addresses) { [fog_address(ip: "1.1.1.1", pool: "swimmers", instance_id: "in-use")] }

        it "fails with the pool name" do
          expect { driver.send(:attach_ip_from_pool, server, "swimmers") }
            .to raise_error(Kitchen::ActionFailed, "No available IPs in pool <swimmers>")
        end
      end

      context "when the pool holds no addresses at all" do
        let(:addresses) { [] }

        it "fails rather than attaching nil" do
          expect { driver.send(:attach_ip_from_pool, server, "swimmers") }
            .to raise_error(Kitchen::ActionFailed, "No available IPs in pool <swimmers>")
        end
      end
    end

    context "when allocating a new address" do
      let(:config) { { floating_ip_pool: "swimmers", allocate_floating_ip: true } }

      let(:networks_body) { { "networks" => [{ "id" => "net-uuid-1" }] } }
      let(:net) do
        fog_network(
          list_networks: fog_response(networks_body),
          create_floating_ip: fog_response(
            "floatingip" => { "floating_ip_address" => "203.0.113.9" }
          )
        )
      end

      before { allow(driver).to receive(:network).and_return(net) }

      it "looks the pool up by name" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(net).to have_received(:list_networks).with(name: "swimmers")
      end

      it "creates a floating IP on the pool's network" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(net).to have_received(:create_floating_ip).with("net-uuid-1")
      end

      it "attaches the newly allocated address" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(server).to have_received(:associate_address).with("203.0.113.9")
      end

      # Only for the rest of this process: `get_ip` returns config[:floating_ip]
      # verbatim when it is set, which saves re-deriving the address it just
      # attached. `destroy` does not read it -- it rebuilds the address from the
      # server's public addresses and :public_ip_order.
      it "records the new address in config for get_ip to reuse" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(driver[:floating_ip]).to eq("203.0.113.9")
        expect(driver.send(:get_ip, server)).to eq("203.0.113.9")
      end

      it "builds only one network connection for the whole sequence" do
        driver.send(:attach_ip_from_pool, server, "swimmers")

        expect(driver).to have_received(:network).once
      end

      # Regression: the old code indexed straight into [0]["id"], so a typo in
      # the pool name surfaced as NoMethodError on nil rather than a usable
      # message.
      context "when no network matches the pool name" do
        let(:networks_body) { { "networks" => [] } }

        it "fails with the pool name" do
          expect { driver.send(:attach_ip_from_pool, server, "typo") }
            .to raise_error(Kitchen::ActionFailed, "Floating IP pool <typo> not found")
        end
      end

      context "when Neutron omits the networks key entirely" do
        let(:networks_body) { {} }

        it "fails with the pool name" do
          expect { driver.send(:attach_ip_from_pool, server, "swimmers") }
            .to raise_error(Kitchen::ActionFailed, "Floating IP pool <swimmers> not found")
        end
      end
    end

    it "serializes pool access across threads" do
      allow(driver).to receive(:compute)
        .and_return(fog_compute(addresses: [fog_address(ip: "1.1.1.4", pool: "swimmers")]))

      expect(Kitchen::Driver::Openstack::Networking::IP_POOL_LOCK).to receive(:synchronize).and_call_original

      driver.send(:attach_ip_from_pool, server, "swimmers")
    end
  end

  describe "#attach_ip" do
    it "associates the address with the server" do
      driver.send(:attach_ip, server, "1.2.3.4")

      expect(server).to have_received(:associate_address).with("1.2.3.4")
    end

    it "reports what it attached" do
      driver.send(:attach_ip, server, "1.2.3.4")

      expect(logged_output.string).to include("Attaching floating IP <1.2.3.4>")
    end
  end

  describe "#get_public_private_ips" do
    it "reads the dedicated accessors when the extension is available" do
      server = fog_server(public_ip_addresses: %w{1.2.3.4}, private_ip_addresses: %w{10.0.0.1})

      expect(driver.send(:get_public_private_ips, server)).to eq([%w{1.2.3.4}, %w{10.0.0.1}])
    end

    # Deployments without the floating IP extension 404 or 403 on the
    # dedicated accessors. See https://github.com/fog/fog/issues/2160
    [Fog::OpenStack::Compute::NotFound, Excon::Errors::Forbidden].each do |error|
      context "when the accessors raise #{error}" do
        let(:server) do
          fog_server(
            addresses: {
              "public" => [{ "addr" => "1.2.3.4" }],
              "private" => [{ "addr" => "10.0.0.1" }],
            }
          )
        end

        before do
          allow(server).to receive(:public_ip_addresses).and_raise(error, "no floating IP extension")
          allow(server).to receive(:private_ip_addresses).and_raise(error, "no floating IP extension")
        end

        it "falls back to the addresses hash" do
          expect(driver.send(:get_public_private_ips, server)).to eq([%w{1.2.3.4}, %w{10.0.0.1}])
        end
      end
    end

    context "when the fallback hash holds only public addresses" do
      let(:server) { fog_server(addresses: { "public" => [{ "addr" => "1.2.3.4" }] }) }

      before { allow(server).to receive(:public_ip_addresses).and_raise(Excon::Errors::Forbidden, "nope") }

      it "returns nil for the missing side" do
        expect(driver.send(:get_public_private_ips, server)).to eq([%w{1.2.3.4}, nil])
      end
    end

    context "when the fallback hash is empty" do
      let(:server) { fog_server(addresses: {}) }

      before { allow(server).to receive(:public_ip_addresses).and_raise(Excon::Errors::Forbidden, "nope") }

      it "returns nils rather than raising" do
        expect(driver.send(:get_public_private_ips, server)).to eq([nil, nil])
      end
    end
  end

  describe "#get_ip" do
    context "when a floating IP is configured" do
      let(:config) { { floating_ip: "1.2.3.4" } }

      it "uses it verbatim" do
        expect(driver.send(:get_ip, server)).to eq("1.2.3.4")
      end

      it "does not wait on the server" do
        driver.send(:get_ip, server)

        expect(server).not_to have_received(:wait_for)
      end
    end

    it "waits for network information before reading addresses" do
      driver.send(:get_ip, server)

      expect(server).to have_received(:wait_for)
    end

    # Driven through the real readiness predicate rather than by stubbing
    # wait_for to raise: a server whose addresses hash stays empty is exactly
    # the state the predicate exists to detect, and the fog_server factory's
    # wait_for raises TimeoutError when the block never goes truthy.
    context "when network information never arrives" do
      let(:server) { fog_server(addresses: {}, public_ip_addresses: [], private_ip_addresses: []) }

      it "fails with a clear message" do
        expect { driver.send(:get_ip, server) }
          .to raise_error(Kitchen::ActionFailed, "Could not get network information (timed out)")
      end
    end

    it "logs how long it waited for network information" do
      driver.send(:get_ip, server)

      expect(logged_output.string).to include("Waited 0 seconds for network information.")
    end

    context "with both public and private addresses" do
      let(:server) { fog_server(public_ip_addresses: %w{1.2.3.4}, private_ip_addresses: %w{10.0.0.1}) }

      it "prefers the public address" do
        expect(driver.send(:get_ip, server)).to eq("1.2.3.4")
      end
    end

    context "with only public addresses" do
      let(:server) { fog_server(public_ip_addresses: %w{1.2.3.4}, private_ip_addresses: []) }

      it "uses the public address" do
        expect(driver.send(:get_ip, server)).to eq("1.2.3.4")
      end
    end

    context "with only private addresses" do
      let(:server) { fog_server(public_ip_addresses: [], private_ip_addresses: %w{10.0.0.1}) }

      it "falls back to the private address" do
        expect(driver.send(:get_ip, server)).to eq("10.0.0.1")
      end
    end

    context "with several addresses on each side" do
      let(:server) do
        fog_server(
          public_ip_addresses: %w{1.2.3.4 5.6.7.8},
          private_ip_addresses: %w{10.0.0.1 10.0.0.2}
        )
      end

      it "honours public_ip_order" do
        config[:public_ip_order] = 1

        expect(driver.send(:get_ip, server)).to eq("5.6.7.8")
      end

      it "accepts a string public_ip_order from YAML" do
        config[:public_ip_order] = "1"

        expect(driver.send(:get_ip, server)).to eq("5.6.7.8")
      end

      it "falls through to private_ip_order when the public index is out of range" do
        config[:public_ip_order] = 5
        config[:private_ip_order] = 1

        expect(driver.send(:get_ip, server)).to eq("10.0.0.2")
      end
    end

    context "when the deployment has no floating IP extension" do
      let(:server) do
        fog_server(
          addresses: {
            "public" => [{ "addr" => "1.2.3.4" }],
            "private" => [{ "addr" => "10.0.0.1" }],
          }
        )
      end

      before do
        allow(server).to receive(:public_ip_addresses).and_raise(Fog::OpenStack::Compute::NotFound, "not found")
        allow(server).to receive(:private_ip_addresses).and_raise(Fog::OpenStack::Compute::NotFound, "not found")
      end

      it "reads the address out of the addresses hash" do
        expect(driver.send(:get_ip, server)).to eq("1.2.3.4")
      end
    end

    context "when the server reports no public or private addresses" do
      let(:server) do
        fog_server(public_ip_addresses: [], private_ip_addresses: [], ip_addresses: %w{10.0.0.9})
      end

      it "falls back to the flat ip_addresses list" do
        expect(driver.send(:get_ip, server)).to eq("10.0.0.9")
      end
    end

    context "when there is no address at all" do
      let(:server) do
        fog_server(public_ip_addresses: [], private_ip_addresses: [], ip_addresses: [])
      end

      it "fails" do
        expect { driver.send(:get_ip, server) }
          .to raise_error(Kitchen::ActionFailed, "Could not find an IP")
      end
    end

    describe "openstack_network_name" do
      let(:config) { { openstack_network_name: "mynet" } }
      let(:server) do
        fog_server(
          addresses: {
            "mynet" => [{ "addr" => "10.0.0.5" }, { "addr" => "fe80::1" }],
            "public" => [{ "addr" => "1.2.3.4" }],
          }
        )
      end

      it "prefers the named network over the public address" do
        expect(driver.send(:get_ip, server)).to eq("10.0.0.5")
      end

      it "returns the IPv6 address when use_ipv6 is set" do
        config[:use_ipv6] = true

        expect(driver.send(:get_ip, server)).to eq("fe80::1")
      end

      # Regression: the old code was a single unguarded expression,
      # `filter_ips(server.addresses[name]).first["addr"]`, which raised
      # NoMethodError on nil in two different ways -- on `select` for a
      # misspelled network name, and on `[]` when the network existed but had
      # no address of the configured family. Both now name what went wrong.
      context "when the server is not on that network" do
        it "fails with the network name" do
          config[:openstack_network_name] = "typo"

          expect { driver.send(:get_ip, server) }
            .to raise_error(Kitchen::ActionFailed, "Server is not attached to network <typo>")
        end
      end

      context "when the network has no address of the requested family" do
        let(:server) { fog_server(addresses: { "mynet" => [{ "addr" => "10.0.0.5" }] }) }

        it "fails naming the family it wanted" do
          config[:use_ipv6] = true

          expect { driver.send(:get_ip, server) }
            .to raise_error(Kitchen::ActionFailed, "No IPv6 address found on network <mynet>")
        end
      end

      context "when the network entry is empty" do
        let(:server) { fog_server(addresses: { "mynet" => [] }) }

        it "fails rather than returning nil" do
          expect { driver.send(:get_ip, server) }
            .to raise_error(Kitchen::ActionFailed, "No IPv4 address found on network <mynet>")
        end
      end
    end
  end

  describe "#filter_ips" do
    let(:addresses) { [{ "addr" => "1.2.3.4" }, { "addr" => "fe80::1" }, { "addr" => "5.6.7.8" }] }

    it "keeps only IPv4 addresses by default" do
      expect(driver.send(:filter_ips, addresses))
        .to eq([{ "addr" => "1.2.3.4" }, { "addr" => "5.6.7.8" }])
    end

    it "keeps only IPv6 addresses when use_ipv6 is set" do
      config[:use_ipv6] = true

      expect(driver.send(:filter_ips, addresses)).to eq([{ "addr" => "fe80::1" }])
    end

    it "returns an empty list when nothing matches" do
      config[:use_ipv6] = true

      expect(driver.send(:filter_ips, [{ "addr" => "1.2.3.4" }])).to eq([])
    end
  end

  describe "#parse_ips" do
    let(:pub)  { %w{1.2.3.4 2001:db8::1} }
    let(:priv) { %w{10.0.0.1 fe80::1} }

    context "with both public and private addresses" do
      it "keeps IPv4 by default" do
        expect(driver.send(:parse_ips, pub, priv)).to eq([%w{1.2.3.4}, %w{10.0.0.1}])
      end

      it "keeps IPv6 when use_ipv6 is set" do
        config[:use_ipv6] = true

        expect(driver.send(:parse_ips, pub, priv)).to eq([%w{2001:db8::1}, %w{fe80::1}])
      end
    end

    context "with only public addresses" do
      it "returns an empty private list" do
        expect(driver.send(:parse_ips, pub, nil)).to eq([%w{1.2.3.4}, []])
      end
    end

    context "with only private addresses" do
      it "returns an empty public list" do
        expect(driver.send(:parse_ips, nil, priv)).to eq([[], %w{10.0.0.1}])
      end
    end

    context "with nothing at all" do
      it "returns two empty lists" do
        expect(driver.send(:parse_ips, nil, nil)).to eq([[], []])
      end
    end

    it "wraps a bare string into a list" do
      expect(driver.send(:parse_ips, "1.2.3.4", "10.0.0.1")).to eq([%w{1.2.3.4}, %w{10.0.0.1}])
    end

    # Regression: this used `select!`, and `Array(x)` returns x itself when x is
    # already an Array -- so the filter ran against the caller's list, which in
    # `get_ip` is the Fog server model's own address data. The earlier version
    # of this example passed `original.dup` and then asserted on `original`,
    # so it could not have failed.
    it "does not mutate the lists it was given" do
      pub  = %w{1.2.3.4 2001:db8::1}
      priv = %w{10.0.0.1 fd00::1}

      driver.send(:parse_ips, pub, priv)

      expect(pub).to eq(%w{1.2.3.4 2001:db8::1})
      expect(priv).to eq(%w{10.0.0.1 fd00::1})
    end

    it "returns lists that are not the ones it was given" do
      pub = %w{1.2.3.4}

      result_pub, = driver.send(:parse_ips, pub, [])

      expect(result_pub).to eq(%w{1.2.3.4})
      expect(result_pub).not_to be(pub)
    end
  end
end
