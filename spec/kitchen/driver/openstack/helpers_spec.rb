# frozen_string_literal: true

require "excon" unless defined?(Excon)
require "ohai" unless defined?(Ohai::System)

RSpec.describe Kitchen::Driver::Openstack::Helpers do
  include_context "with a configured driver"

  let(:state) { { hostname: "192.0.2.10", server_id: "test123" } }

  describe "#hints_path" do
    it "returns ohai's first configured hints directory" do
      allow(Ohai).to receive(:config).and_return(hints_path: %w{/etc/chef/ohai/hints /other})

      expect(driver.send(:hints_path)).to eq("/etc/chef/ohai/hints")
    end
  end

  describe "#add_ohai_hint" do
    let(:connection) { instance_double(Kitchen::Transport::Dummy::Connection, execute: true) }

    before do
      allow(transport).to receive(:connection).with(state).and_return(connection)
      allow(driver).to receive(:hints_path).and_return("/etc/chef/ohai/hints")
    end

    context "on a Bourne-shell platform" do
      before { allow(driver).to receive_messages(bourne_shell?: true, windows_os?: false) }

      it "creates the hints directory and the hint file in one command" do
        driver.send(:add_ohai_hint, state)

        expect(connection).to have_received(:execute).with(
          "sudo mkdir -p /etc/chef/ohai/hints && " \
          "sudo bash -c 'echo {} > /etc/chef/ohai/hints/openstack.json'"
        )
      end

      it "tells the user what it is doing" do
        driver.send(:add_ohai_hint, state)

        expect(logged_output.string).to include("Adding OpenStack hint for ohai")
      end
    end

    context "on Windows" do
      before { allow(driver).to receive_messages(bourne_shell?: false, windows_os?: true) }

      it "creates the hint file with PowerShell" do
        driver.send(:add_ohai_hint, state)

        expect(connection).to have_received(:execute).with(
          "New-Item /etc/chef/ohai/hints\\openstack.json -Value '{}' -Force -Type file"
        )
      end
    end

    context "on an unrecognized platform" do
      before { allow(driver).to receive_messages(bourne_shell?: false, windows_os?: false) }

      it "does not open a transport session" do
        driver.send(:add_ohai_hint, state)

        expect(connection).not_to have_received(:execute)
      end

      it "says why it skipped" do
        driver.send(:add_ohai_hint, state)

        expect(logged_output.string).to include("skipping the OpenStack ohai hint")
      end
    end
  end

  describe "#disable_ssl_validation" do
    around do |example|
      previous = Excon.defaults[:ssl_verify_peer]
      example.run
      Excon.defaults[:ssl_verify_peer] = previous
    end

    it "turns off Excon peer verification" do
      Excon.defaults[:ssl_verify_peer] = true

      driver.send(:disable_ssl_validation)

      expect(Excon.defaults[:ssl_verify_peer]).to be(false)
    end
  end

  describe "#countdown" do
    before { allow(Kernel).to receive(:print) }

    it "prints a dot for each tick" do
      # Two ticks' worth of wall clock: start, +10, then done.
      now = Time.now
      allow(Time).to receive(:now).and_return(now, now, now + 10, now + 20)

      driver.send(:countdown, 20)

      expect(Kernel).to have_received(:print).with(".").twice
    end

    it "sleeps between ticks rather than spinning" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now, now, now + 30)

      driver.send(:countdown, 20)

      expect(driver).to have_received(:sleep).with(described_class::COUNTDOWN_TICK)
    end

    it "does nothing when the duration has already elapsed" do
      driver.send(:countdown, 0)

      expect(Kernel).not_to have_received(:print)
    end
  end

  describe "#wait_for_server" do
    let(:connection) { instance_double(Kitchen::Transport::Dummy::Connection, wait_until_ready: true) }

    before { allow(transport).to receive(:connection).with(state).and_return(connection) }

    it "waits for the transport to report ready" do
      driver.send(:wait_for_server, state)

      expect(connection).to have_received(:wait_until_ready)
    end

    it "does not sleep when no server_wait is configured" do
      allow(driver).to receive(:countdown)

      driver.send(:wait_for_server, state)

      expect(driver).not_to have_received(:countdown)
    end

    context "with server_wait configured" do
      let(:config) { { server_wait: 30 } }

      before { allow(driver).to receive(:countdown) }

      it "counts down before checking readiness" do
        driver.send(:wait_for_server, state)

        expect(driver).to have_received(:countdown).with(30)
      end

      it "tells the user it is waiting" do
        driver.send(:wait_for_server, state)

        expect(logged_output.string).to include("Sleeping for 30 seconds")
      end
    end

    context "when the server never becomes reachable" do
      before do
        allow(connection).to receive(:wait_until_ready).and_raise(Kitchen::Transport::TransportFailed, "timed out")
        allow(driver).to receive(:destroy)
      end

      it "destroys the unreachable server" do
        expect { driver.send(:wait_for_server, state) }.to raise_error(Kitchen::Transport::TransportFailed)

        expect(driver).to have_received(:destroy).with(state)
      end

      it "re-raises the original failure" do
        expect { driver.send(:wait_for_server, state) }
          .to raise_error(Kitchen::Transport::TransportFailed, /timed out/)
      end

      it "logs the host, the id and the underlying reason" do
        expect { driver.send(:wait_for_server, state) }.to raise_error(Kitchen::Transport::TransportFailed)

        expect(logged_output.string).to include("192.0.2.10", "test123", "timed out")
      end
    end
  end
end
