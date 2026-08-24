# frozen_string_literal: true

RSpec.describe Kitchen::Driver::Openstack do
  include_context "with a configured driver"

  let(:state)  { {} }
  let(:server) { fog_server }

  describe "plugin metadata" do
    it "implements driver API version 2" do
      expect(described_class.instance_variable_get(:@api_version)).to eq(2)
    end

    it "reports the gem version as its plugin version" do
      expect(described_class.instance_variable_get(:@plugin_version))
        .to eq(Kitchen::Driver::OPENSTACK_VERSION)
    end
  end

  describe "default config" do
    {
      port: "22",
      use_ipv6: false,
      private_ip_order: 0,
      public_ip_order: 0,
      no_ssh_tcp_check: false,
      no_ssh_tcp_check_sleep: 120,
      glance_cache_wait_timeout: 600,
      allocate_floating_ip: false,
      connect_timeout: 60,
      read_timeout: 60,
      write_timeout: 60,
    }.each do |key, value|
      it "defaults #{key} to #{value.inspect}" do
        expect(driver[key]).to eq(value)
      end
    end

    %i{
      openstack_cloud clouds_yaml_path server_name server_name_prefix key_name
      openstack_project_name openstack_region openstack_service_name
      openstack_network_name floating_ip_pool floating_ip availability_zone
      security_groups network_ref network_id block_device_mapping metadata
    }.each do |key|
      it "leaves #{key} unset" do
        expect(driver[key]).to be_nil
      end
    end

    it "lets kitchen.yml override a default" do
      config[:port] = "2222"

      expect(driver[:port]).to eq("2222")
    end
  end

  describe "#create" do
    let(:config) { { server_name: "hello", image_id: "111", flavor_id: "1" } }

    before do
      allow(driver).to receive_messages(
        create_server: server,
        get_ip: "1.2.3.4",
        wait_for_server: true,
        add_ohai_hint: true
      )
    end

    it "records the server id in state" do
      driver.create(state)

      expect(state[:server_id]).to eq("test123")
    end

    it "records the hostname in state" do
      driver.create(state)

      expect(state[:hostname]).to eq("1.2.3.4")
    end

    it "resolves the server name before creating" do
      config.delete(:server_name)
      allow(driver).to receive(:config_server_name).and_call_original

      driver.create(state)

      expect(driver[:server_name]).not_to be_nil
    end

    it "waits for the server to become ready" do
      driver.create(state)

      expect(server).to have_received(:wait_for).with(600)
    end

    it "honours a custom glance cache timeout" do
      config[:glance_cache_wait_timeout] = 42

      driver.create(state)

      expect(server).to have_received(:wait_for).with(42)
    end

    it "waits for the transport before adding the ohai hint" do
      driver.create(state)

      expect(driver).to have_received(:wait_for_server).with(state).ordered
      expect(driver).to have_received(:add_ohai_hint).with(state).ordered
    end

    context "when the server already exists" do
      let(:state) { { server_id: "existing" } }

      it "does not create another one" do
        driver.create(state)

        expect(driver).not_to have_received(:create_server)
      end

      it "says so" do
        driver.create(state)

        expect(logged_output.string).to include("hello (existing) already exists.")
      end

      it "leaves state untouched" do
        driver.create(state)

        expect(state).to eq(server_id: "existing")
      end
    end

    context "while the server is building" do
      # No re-stub of wait_for here: the shared fog_server factory already
      # evaluates the readiness block in the server's own context.

      it "runs the readiness check" do
        driver.create(state)

        expect(server).to have_received(:ready?)
      end

      it "checks for a failed build before reporting ready" do
        driver.create(state)

        expect(server).to have_received(:failed?)
      end

      it "says the server was created" do
        driver.create(state)

        expect(logged_output.string).to include("OpenStack server ID <test123> created")
      end
    end

    context "when the build fails" do
      let(:server) { fog_server(failed?: true, ready?: false) }

      it "raises InstanceFailure naming the server" do
        expect { driver.create(state) }
          .to raise_error(Kitchen::InstanceFailure, /OpenStack server ID <test123> build failed/)
      end
    end

    describe "SSL validation" do
      before { allow(driver).to receive(:disable_ssl_validation) }

      it "is left alone by default" do
        driver.create(state)

        expect(driver).not_to have_received(:disable_ssl_validation)
      end

      it "is disabled when configured" do
        config[:disable_ssl_validation] = true

        driver.create(state)

        expect(driver).to have_received(:disable_ssl_validation)
      end
    end

    describe "floating IPs" do
      before do
        allow(driver).to receive(:attach_ip)
        allow(driver).to receive(:attach_ip_from_pool)
      end

      it "attaches nothing by default" do
        driver.create(state)

        expect(driver).not_to have_received(:attach_ip)
        expect(driver).not_to have_received(:attach_ip_from_pool)
      end

      it "attaches an explicitly configured floating IP" do
        config[:floating_ip] = "203.0.113.5"

        driver.create(state)

        expect(driver).to have_received(:attach_ip).with(server, "203.0.113.5")
      end

      it "attaches from the pool when only a pool is configured" do
        config[:floating_ip_pool] = "swimmers"

        driver.create(state)

        expect(driver).to have_received(:attach_ip_from_pool).with(server, "swimmers")
      end

      it "prefers an explicit floating IP over the pool" do
        config[:floating_ip] = "203.0.113.5"
        config[:floating_ip_pool] = "swimmers"

        driver.create(state)

        expect(driver).to have_received(:attach_ip).with(server, "203.0.113.5")
        expect(driver).not_to have_received(:attach_ip_from_pool)
      end
    end

    describe "error translation" do
      it "wraps Fog errors in ActionFailed" do
        allow(driver).to receive(:create_server).and_raise(Fog::Errors::Error, "boom")

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed, "boom")
      end

      it "wraps Excon errors in ActionFailed" do
        allow(driver).to receive(:create_server).and_raise(Excon::Errors::SocketError.new(StandardError.new("no route")))

        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed, /no route/)
      end

      it "lets InstanceFailure through untouched" do
        allow(driver).to receive(:create_server).and_raise(Kitchen::InstanceFailure, "nope")

        expect { driver.create(state) }.to raise_error(Kitchen::InstanceFailure, "nope")
      end
    end
  end

  describe "#finalize_config!" do
    it "returns itself for chaining" do
      expect(driver.finalize_config!(instance)).to be(driver)
    end

    it "merges clouds.yaml values into config" do
      allow(driver).to receive(:apply_clouds_config) do
        driver.send(:config)[:openstack_username] = "from-clouds-yaml"
      end

      driver.finalize_config!(instance)

      expect(driver[:openstack_username]).to eq("from-clouds-yaml")
    end

    it "applies the clouds config exactly once" do
      allow(driver).to receive(:apply_clouds_config)

      driver.finalize_config!(instance)

      expect(driver).to have_received(:apply_clouds_config).once
    end

    it "still runs the base class finalization" do
      driver.finalize_config!(instance)

      expect(driver.instance).to be(instance)
    end
  end

  describe "#status" do
    let(:servers) { double("Fog servers collection", get: server) }
    let(:compute) { fog_compute(servers: servers) }

    before { allow(driver).to receive(:compute).and_return(compute) }

    it "reports an unknown status when state names no server" do
      expect(driver.status({})).to include(live: nil, state: "unknown")
    end

    it "reports an unknown status when Nova does not know the server" do
      allow(servers).to receive(:get).with("gone").and_return(nil)

      expect(driver.status(server_id: "gone")).to include(state: "unknown")
    end

    context "with an ACTIVE server" do
      let(:server) { fog_server(state: "ACTIVE") }

      it "reports it as live" do
        expect(driver.status(server_id: "test123")).to include(
          live: true, state: "ACTIVE", source: "driver", resource_id: "test123"
        )
      end

      it "stamps when the check happened" do
        expect(driver.status(server_id: "test123")[:checked_at])
          .to match(/\A\d{4}-\d{2}-\d{2}T/)
      end
    end

    context "with a server Nova has not finished building" do
      let(:server) { fog_server(state: "BUILD") }

      it "reports it as not live" do
        expect(driver.status(server_id: "test123"))
          .to include(live: false, state: "BUILD")
      end
    end

    context "with a server in ERROR" do
      let(:server) { fog_server(state: "ERROR") }

      it "reports it as not live but names the state" do
        expect(driver.status(server_id: "test123"))
          .to include(live: false, state: "ERROR")
      end
    end

    it "reports an unknown status when the cloud cannot be reached" do
      allow(servers).to receive(:get).and_raise(Excon::Errors::SocketError.new(StandardError.new("boom")))

      expect(driver.status(server_id: "test123")).to include(state: "unknown")
    end
  end

  describe "#doctor" do
    let(:servers) { double("Fog servers collection", summary: []) }
    let(:compute) { fog_compute(servers: servers) }
    let(:config) do
      {
        openstack_username: "user", openstack_api_key: "secret",
        openstack_auth_url: "https://keystone.example.com/v3",
        image_id: "img-1", flavor_id: "flavor-1"
      }
    end

    before { allow(driver).to receive(:compute).and_return(compute) }

    def doctor_messages
      messages = []
      allow(driver).to receive(:warn) { |m| messages << m }
      [driver.doctor({}), messages]
    end

    it "passes on a complete configuration" do
      found, messages = doctor_messages

      expect(found).to be(false)
      expect(messages).to be_empty
    end

    context "with no credentials at all" do
      let(:config) { { image_id: "img-1", flavor_id: "flavor-1" } }

      it "names each missing setting and where it can come from" do
        found, messages = doctor_messages

        expect(found).to be(true)
        joined = messages.join("\n")
        expect(joined).to include("openstack_username is not set")
        expect(joined).to include("OS_PASSWORD")
        expect(joined).to include("clouds.yaml")
      end

      it "does not also complain about a connection it never tried" do
        _found, messages = doctor_messages

        expect(messages.join("\n")).not_to include("rejected the configured credentials")
      end
    end

    it "reports credentials Keystone rejects" do
      allow(servers).to receive(:summary).and_raise(Excon::Errors::Unauthorized.new("401"))

      found, messages = doctor_messages

      expect(found).to be(true)
      expect(messages.join("\n")).to include("rejected the configured credentials")
    end

    context "with both image_id and image_ref" do
      let(:config) do
        {
          openstack_username: "user", openstack_api_key: "secret",
          openstack_auth_url: "https://keystone.example.com/v3",
          image_id: "img-1", image_ref: "ubuntu", flavor_id: "flavor-1"
        }
      end

      it "reports the conflict create would raise on" do
        found, messages = doctor_messages

        expect(found).to be(true)
        expect(messages.join("\n")).to include("Both image_id and image_ref are set")
      end
    end

    context "with both flavor_id and flavor_ref" do
      let(:config) do
        {
          openstack_username: "user", openstack_api_key: "secret",
          openstack_auth_url: "https://keystone.example.com/v3",
          image_id: "img-1", flavor_id: "flavor-1", flavor_ref: "m1.small"
        }
      end

      it "reports the conflict create would raise on" do
        found, messages = doctor_messages

        expect(found).to be(true)
        expect(messages.join("\n")).to include("Both flavor_id and flavor_ref are set")
      end
    end

    context "with neither an image nor a flavor selected" do
      let(:config) do
        {
          openstack_username: "user", openstack_api_key: "secret",
          openstack_auth_url: "https://keystone.example.com/v3"
        }
      end

      it "reports both gaps" do
        found, messages = doctor_messages

        expect(found).to be(true)
        joined = messages.join("\n")
        expect(joined).to include("Neither image_id nor image_ref is set")
        expect(joined).to include("Neither flavor_id nor flavor_ref is set")
      end
    end
  end

  describe "#destroy" do
    let(:state)   { { server_id: "test123", hostname: "1.2.3.4" } }
    let(:servers) { double("Fog servers collection", get: server) }
    let(:compute) { fog_compute(servers: servers) }

    before { allow(driver).to receive(:compute).and_return(compute) }

    it "destroys the server" do
      driver.destroy(state)

      expect(server).to have_received(:destroy)
    end

    it "clears the server id from state" do
      driver.destroy(state)

      expect(state).not_to have_key(:server_id)
    end

    it "clears the hostname from state" do
      driver.destroy(state)

      expect(state).not_to have_key(:hostname)
    end

    it "says what it destroyed" do
      driver.destroy(state)

      expect(logged_output.string).to include("OpenStack instance <test123> destroyed.")
    end

    context "with no server id in state" do
      let(:state) { {} }

      it "does nothing" do
        driver.destroy(state)

        expect(driver).not_to have_received(:compute)
      end
    end

    context "when the server is already gone" do
      let(:servers) { double("Fog servers collection", get: nil) }

      it "does not raise" do
        expect { driver.destroy(state) }.not_to raise_error
      end

      it "still clears state" do
        driver.destroy(state)

        expect(state).to be_empty
      end
    end

    describe "SSL validation" do
      before { allow(driver).to receive(:disable_ssl_validation) }

      it "is disabled when configured" do
        config[:disable_ssl_validation] = true

        driver.destroy(state)

        expect(driver).to have_received(:disable_ssl_validation)
      end
    end

    describe "releasing an allocated floating IP" do
      let(:config) { { floating_ip_pool: "swimmers", allocate_floating_ip: true } }
      let(:server) { fog_server(public_ip_addresses: %w{203.0.113.9}, private_ip_addresses: %w{10.0.0.1}) }

      let(:floating_ips_body) { { "floatingips" => [{ "id" => "fip-1" }] } }
      let(:net) do
        fog_network(
          list_floating_ips: fog_response(floating_ips_body),
          delete_floating_ip: true
        )
      end

      before { allow(driver).to receive(:network).and_return(net) }

      it "looks the floating IP up by address" do
        driver.destroy(state)

        expect(net).to have_received(:list_floating_ips).with(floating_ip_address: "203.0.113.9")
      end

      it "deletes it" do
        driver.destroy(state)

        expect(net).to have_received(:delete_floating_ip).with("fip-1")
      end

      it "still destroys the server" do
        driver.destroy(state)

        expect(server).to have_received(:destroy)
      end

      it "honours public_ip_order when picking the address to release" do
        allow(server).to receive(:public_ip_addresses).and_return(%w{203.0.113.9 203.0.113.10})
        config[:public_ip_order] = 1

        driver.destroy(state)

        expect(net).to have_received(:list_floating_ips).with(floating_ip_address: "203.0.113.10")
      end

      # Regression: the old code indexed straight into [0]["id"], so an IP
      # Neutron had already reclaimed took the whole destroy down with a
      # NoMethodError, stranding the server.
      context "when Neutron no longer knows the address" do
        let(:floating_ips_body) { { "floatingips" => [] } }

        it "does not raise" do
          expect { driver.destroy(state) }.not_to raise_error
        end

        it "still destroys the server" do
          driver.destroy(state)

          expect(server).to have_received(:destroy)
        end

        it "warns that there was nothing to release" do
          driver.destroy(state)

          expect(logged_output.string).to include("No floating IP found matching <203.0.113.9>")
        end
      end

      context "when the server has no public address" do
        let(:server) { fog_server(public_ip_addresses: [], private_ip_addresses: %w{10.0.0.1}) }

        it "does not try to release anything" do
          driver.destroy(state)

          expect(net).not_to have_received(:list_floating_ips)
        end
      end

      context "when allocate_floating_ip is not set" do
        let(:config) { { floating_ip_pool: "swimmers" } }

        it "leaves the address alone, since the driver did not allocate it" do
          driver.destroy(state)

          expect(net).not_to have_received(:list_floating_ips)
        end
      end
    end
  end

  describe "#openstack_server" do
    let(:config) do
      {
        openstack_username: "twilight",
        openstack_api_key: "sparkle",
        openstack_auth_url: "http://keystone.example.com:5000/v3",
        openstack_domain_id: "default",
      }
    end

    it "always sends the required settings" do
      expect(driver.send(:openstack_server)).to include(
        openstack_username: "twilight",
        openstack_api_key: "sparkle",
        openstack_auth_url: "http://keystone.example.com:5000/v3",
        openstack_domain_id: "default"
      )
    end

    it "sends required settings even when nil" do
      config[:openstack_domain_id] = nil

      expect(driver.send(:openstack_server)).to have_key(:openstack_domain_id)
    end

    it "includes optional settings that are set" do
      config[:openstack_region] = "atlantis"

      expect(driver.send(:openstack_server)).to include(openstack_region: "atlantis")
    end

    it "omits optional settings that are not set" do
      expect(driver.send(:openstack_server)).not_to have_key(:openstack_region)
    end

    describe "connection options" do
      it "carries the timeouts" do
        expect(driver.send(:openstack_server)[:connection_options])
          .to eq(read_timeout: 60, write_timeout: 60, connect_timeout: 60)
      end

      # Regression: ssl_ca_file is an Excon option, not a Fog one, so a CA
      # bundle from OS_CACERT or clouds.yaml used to be parsed and dropped.
      it "carries a custom CA bundle through to Excon" do
        config[:ssl_ca_file] = "/etc/ssl/certs/private-ca.pem"

        expect(driver.send(:openstack_server)[:connection_options])
          .to include(ssl_ca_file: "/etc/ssl/certs/private-ca.pem")
      end

      it "does not leak the CA bundle into the Fog settings" do
        config[:ssl_ca_file] = "/etc/ssl/certs/private-ca.pem"

        expect(driver.send(:openstack_server)).not_to have_key(:ssl_ca_file)
      end
    end

    describe "string coercion" do
      # Fog::Service#coerce_options turns anything that looks numeric back into
      # an Integer, which then breaks the auth token builder.
      described_class::FOG_STRING_SETTINGS.each do |setting|
        next if setting == :openstack_identity_api_version

        it "stringifies a numeric #{setting}" do
          config[setting] = 12345

          expect(driver.send(:openstack_server)[setting]).to eq("12345")
        end
      end

      it "leaves nil values alone" do
        config[:openstack_username] = nil

        expect(driver.send(:openstack_server)[:openstack_username]).to be_nil
      end

      it "leaves settings outside the list alone" do
        config[:openstack_service_type] = %w{compute}

        expect(driver.send(:openstack_server)[:openstack_service_type]).to eq(%w{compute})
      end
    end
  end

  describe "#normalize_identity_api_version" do
    {
      3 => "v3",
      "3" => "v3",
      3.0 => "v3.0",
      2 => "v2.0",
      "2" => "v2.0",
      "2.0" => "v2.0",
      "v2.0" => "v2.0",
      "v3" => "v3",
      "V3" => "V3",
      " 3 " => "v3",
      "" => "",
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(driver.send(:normalize_identity_api_version, input)).to eq(expected)
      end
    end

    it "is applied through openstack_server" do
      config[:openstack_identity_api_version] = 3

      expect(driver.send(:openstack_server)[:openstack_identity_api_version]).to eq("v3")
    end
  end

  describe "#required_server_settings" do
    it "names the four settings Fog cannot authenticate without" do
      expect(driver.send(:required_server_settings))
        .to eq(%i{openstack_username openstack_api_key openstack_auth_url openstack_domain_id})
    end
  end

  describe "#optional_server_settings" do
    subject(:optional) { driver.send(:optional_server_settings) }

    it "covers every openstack_* setting Fog recognizes" do
      expect(optional).to include(:openstack_region, :openstack_project_name, :openstack_tenant)
    end

    it "excludes the required settings" do
      expect(optional).not_to include(*driver.send(:required_server_settings))
    end

    it "excludes settings Fog does not recognize" do
      expect(optional).not_to include(:openstack_network_name)
    end
  end

  describe "Fog service construction" do
    let(:config) do
      {
        openstack_username: "twilight",
        openstack_api_key: "sparkle",
        openstack_auth_url: "http://keystone.example.com:5000/v3",
        openstack_domain_id: "default",
      }
    end

    it "builds compute from the resolved settings" do
      allow(Fog::OpenStack::Compute).to receive(:new) { |args| args }

      expect(driver.send(:compute)).to include(openstack_username: "twilight")
    end

    it "builds network from the resolved settings" do
      allow(Fog::OpenStack::Network).to receive(:new) { |args| args }

      expect(driver.send(:network)).to include(openstack_username: "twilight")
    end

    it "builds the volume helper with the driver's logger" do
      expect(driver.send(:volume)).to be_a(Kitchen::Driver::Openstack::Volume)
    end
  end

  describe "#get_bdm" do
    it "delegates to the volume helper with the Fog settings" do
      helper = instance_double(Kitchen::Driver::Openstack::Volume, get_bdm: { volume_id: "vol-1" })
      allow(driver).to receive(:volume).and_return(helper)

      expect(driver.send(:get_bdm, config)).to eq(volume_id: "vol-1")
      expect(helper).to have_received(:get_bdm).with(config, driver.send(:openstack_server))
    end
  end
end
