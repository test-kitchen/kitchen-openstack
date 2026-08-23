# frozen_string_literal: true

require "logger"
require "stringio" unless defined?(StringIO)

RSpec.describe Kitchen::Driver::Openstack::Volume do
  subject(:vol_driver) { described_class.new(logger) }

  let(:logger_io) { StringIO.new }
  let(:logger)    { Kitchen::Logger.new(logdev: logger_io) }

  # No unit test waits on the wall clock.
  before { allow(vol_driver).to receive(:sleep).and_return(0) }

  let(:os) do
    {
      openstack_username: "twilight",
      openstack_domain_id: "default",
      openstack_api_key: "sparkle",
      openstack_auth_url: "http://keystone.example.com:5000/v3",
      openstack_project_name: "trixie",
      openstack_region: "syd",
    }
  end

  # A Cinder volume model. `wait_for` is what the driver actually blocks on, so
  # the double follows Fog's contract rather than just running the block once:
  # the block is evaluated in the model's own context, and a block that never
  # goes truthy raises Fog::Errors::TimeoutError. Without that last part a
  # never-ready volume would be indistinguishable from a ready one.
  def volume_model(id: "555", status: "available", ready: true)
    model = double("Fog volume #{id}", id: id, status: status, ready?: ready)
    allow(model).to receive(:sleep).and_return(0)
    allow(model).to receive(:wait_for) do |_timeout, &blk|
      result = model.instance_exec(&blk)
      raise Fog::Errors::TimeoutError, "The specified wait_for timeout was exceeded" unless result

      result
    end
    model
  end

  # The `volumes` collection only answers `get`, which is a direct GET by id.
  # Nothing stubs iteration, so a driver that went back to scanning the listing
  # would fail loudly here rather than quietly depending on page one.
  def cinder(volumes: [volume_model], create_response: { body: { "volume" => { "id" => "555" } } })
    collection = double("Fog volumes collection")
    allow(collection).to receive(:get) { |id| volumes.find { |v| v.id == id } }
    double("Fog::OpenStack::Volume", volumes: collection, create_volume: create_response)
  end

  describe "#volume" do
    it "builds a Cinder connection from the given Fog settings" do
      allow(Fog::OpenStack::Volume).to receive(:new).with(os).and_return(:cinder)

      expect(vol_driver.volume(os)).to eq(:cinder)
    end
  end

  describe "#create_volume" do
    let(:config) do
      {
        server_name: "applejack",
        block_device_mapping: {
          snapshot_id: "444",
          volume_size: "5",
          creation_timeout: 30,
        },
      }
    end

    let(:cinder_service) { cinder }

    before { allow(vol_driver).to receive(:volume).and_return(cinder_service) }

    it "returns the id of the created volume" do
      expect(vol_driver.create_volume(config, os)).to eq("555")
    end

    it "names the volume after the server" do
      vol_driver.create_volume(config, os)

      expect(cinder_service).to have_received(:create_volume)
        .with("applejack-volume", "applejack volume", "5", hash_including(snapshot_id: "444"))
    end

    it "forwards only the recognized vanilla options to Cinder" do
      config[:block_device_mapping].merge!(
        volume_type: "ssd",
        availability_zone: "az1",
        delete_on_termination: true,
        device_name: "vda"
      )

      vol_driver.create_volume(config, os)

      expect(cinder_service).to have_received(:create_volume)
        .with(anything, anything, anything,
          { snapshot_id: "444", volume_type: "ssd", availability_zone: "az1" })
    end

    it "omits vanilla options that are not set" do
      config[:block_device_mapping] = { volume_size: "5" }

      vol_driver.create_volume(config, os)

      expect(cinder_service).to have_received(:create_volume).with(anything, anything, anything, {})
    end

    it "authenticates to Cinder once and reuses the connection" do
      vol_driver.create_volume(config, os)

      expect(vol_driver).to have_received(:volume).once
    end

    # Regression: `Array#first` silently ignores a block, so the original
    # implementation waited on whichever volume happened to be first in the
    # account rather than the one it had just created. The id from the create
    # response is now looked up directly.
    context "when the account holds several volumes" do
      let(:other) { volume_model(id: "111", status: "error") }
      let(:mine)  { volume_model(id: "555", status: "available") }
      let(:cinder_service) { cinder(volumes: [other, mine]) }

      it "fetches the volume it just created by id" do
        expect(vol_driver.create_volume(config, os)).to eq("555")

        expect(cinder_service.volumes).to have_received(:get).with("555")
        expect(mine).to have_received(:wait_for)
        expect(other).not_to have_received(:wait_for)
      end
    end

    context "when the created volume cannot be found afterwards" do
      let(:cinder_service) { cinder(volumes: [volume_model(id: "999")]) }

      it "raises an ActionFailed rather than dereferencing nil" do
        expect { vol_driver.create_volume(config, os) }
          .to raise_error(Kitchen::ActionFailed, /Volume 555 disappeared/)
      end
    end

    context "when the volume goes to error state" do
      let(:cinder_service) { cinder(volumes: [volume_model(status: "error")]) }

      it "raises an ActionFailed naming the volume" do
        expect { vol_driver.create_volume(config, os) }
          .to raise_error(Kitchen::ActionFailed, "Failed to make volume 555")
      end
    end

    it "treats the error status case-insensitively" do
      service = cinder(volumes: [volume_model(status: "ERROR")])
      allow(vol_driver).to receive(:volume).and_return(service)

      expect { vol_driver.create_volume(config, os) }
        .to raise_error(Kitchen::ActionFailed, "Failed to make volume 555")
    end

    # `create` only rescues Fog and Excon errors, so anything else raised from
    # here reaches the user as a raw backtrace instead of a Kitchen failure.
    it "raises only errors that create/1 knows how to present" do
      service = cinder(volumes: [volume_model(status: "error")])
      allow(vol_driver).to receive(:volume).and_return(service)

      expect { vol_driver.create_volume(config, os) }
        .to raise_error(an_instance_of(Kitchen::ActionFailed))
    end

    context "when the volume never becomes ready" do
      let(:cinder_service) { cinder(volumes: [volume_model(ready: false)]) }

      it "surfaces the Fog timeout" do
        expect { vol_driver.create_volume(config, os) }
          .to raise_error(Fog::Errors::TimeoutError)
      end
    end

    describe "timeouts" do
      it "uses the default creation timeout when none is given" do
        config[:block_device_mapping].delete(:creation_timeout)
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        vol_driver.create_volume(config, os)

        expect(model).to have_received(:wait_for).with(described_class::DEFAULT_CREATION_TIMEOUT)
      end

      it "uses the configured creation timeout" do
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        vol_driver.create_volume(config, os)

        expect(model).to have_received(:wait_for).with(30)
      end

      # Regression: YAML parses a quoted timeout as a String, and the old code
      # then compared a String to an Integer.
      it "accepts string timeouts from YAML" do
        config[:block_device_mapping][:creation_timeout] = "30"
        config[:block_device_mapping][:attach_timeout] = "5"
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        expect { vol_driver.create_volume(config, os) }.not_to raise_error
        expect(model).to have_received(:wait_for).with(30)
      end

      it "falls back to the default when the key is present but empty" do
        config[:block_device_mapping][:creation_timeout] = nil
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        vol_driver.create_volume(config, os)

        expect(model).to have_received(:wait_for).with(described_class::DEFAULT_CREATION_TIMEOUT)
      end

      it "sleeps for the attach timeout when one is set" do
        config[:block_device_mapping][:attach_timeout] = 5

        vol_driver.create_volume(config, os)

        expect(vol_driver).to have_received(:sleep).with(5)
      end

      it "does not sleep when the attach timeout is zero" do
        config[:block_device_mapping][:attach_timeout] = 0

        vol_driver.create_volume(config, os)

        expect(vol_driver).not_to have_received(:sleep)
      end

      it "does not sleep when no attach timeout is configured" do
        vol_driver.create_volume(config, os)

        expect(vol_driver).not_to have_received(:sleep)
      end

      # Regression: a bare `Integer("010")` reads the leading zero as octal and
      # returns 8, so a user asking for 10 seconds silently got 8. `Integer("08")`
      # is not even a legal octal literal and raised.
      it "reads a zero-padded timeout as base 10" do
        config[:block_device_mapping][:creation_timeout] = "010"
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        vol_driver.create_volume(config, os)

        expect(model).to have_received(:wait_for).with(10)
      end

      it "accepts a zero-padded timeout that is not a legal octal literal" do
        config[:block_device_mapping][:creation_timeout] = "08"
        model = volume_model
        allow(vol_driver).to receive(:volume).and_return(cinder(volumes: [model]))

        vol_driver.create_volume(config, os)

        expect(model).to have_received(:wait_for).with(8)
      end

      it "names the offending key when a timeout is not a number" do
        config[:block_device_mapping][:creation_timeout] = "soon"

        expect { vol_driver.create_volume(config, os) }
          .to raise_error(Kitchen::ActionFailed, /creation_timeout must be a number, got "soon"/)
      end

      # `attach_timeout: yes` parses as the Boolean true, which Integer() answers
      # with a TypeError rather than an ArgumentError.
      it "rejects a non-numeric YAML scalar without leaking a TypeError" do
        config[:block_device_mapping][:attach_timeout] = true

        expect { vol_driver.create_volume(config, os) }
          .to raise_error(Kitchen::ActionFailed, /attach_timeout must be a number, got true/)
      end

      # Both timeouts are pure config parsing. Validating them after the Cinder
      # call would strand a real volume whose id lives only in the server
      # definition that is now being discarded, so `kitchen destroy` cannot
      # reach it.
      it "rejects a bad timeout before creating any volume" do
        config[:block_device_mapping][:creation_timeout] = "soon"

        expect { vol_driver.create_volume(config, os) }.to raise_error(Kitchen::ActionFailed)

        expect(cinder_service).not_to have_received(:create_volume)
      end

      it "rejects a bad attach timeout before creating any volume" do
        config[:block_device_mapping][:attach_timeout] = "later"

        expect { vol_driver.create_volume(config, os) }.to raise_error(Kitchen::ActionFailed)

        expect(cinder_service).not_to have_received(:create_volume)
      end
    end
  end

  describe "#get_bdm" do
    let(:config) do
      {
        block_device_mapping: {
          make_volume: true,
          snapshot_id: "333",
          volume_id: "555",
          volume_size: "5",
          device_name: "vda",
          delete_on_termination: true,
        },
      }
    end

    before { allow(vol_driver).to receive(:create_volume).and_return("999") }

    it "strips the driver-only keys Nova does not understand" do
      expect(vol_driver.get_bdm(config, os)).to eq(
        volume_id: "999",
        volume_size: "5",
        device_name: "vda",
        delete_on_termination: true
      )
    end

    it "creates a volume and uses its id when make_volume is set" do
      expect(vol_driver.get_bdm(config, os)[:volume_id]).to eq("999")
      expect(vol_driver).to have_received(:create_volume).with(config, os)
    end

    context "when make_volume is not set" do
      before { config[:block_device_mapping][:make_volume] = false }

      it "keeps the volume id the user supplied" do
        expect(vol_driver.get_bdm(config, os)[:volume_id]).to eq("555")
      end

      it "does not create a volume" do
        vol_driver.get_bdm(config, os)

        expect(vol_driver).not_to have_received(:create_volume)
      end
    end

    # Regression: the old implementation mutated config[:block_device_mapping]
    # in place, so a second call (a retried create, or `kitchen diagnose` after
    # a create) saw a hash that had already had its keys stripped.
    it "does not mutate the caller's config" do
      before_call = Marshal.load(Marshal.dump(config))

      vol_driver.get_bdm(config, os)

      expect(config).to eq(before_call)
    end

    it "is idempotent across repeated calls" do
      first = vol_driver.get_bdm(config, os)

      expect(vol_driver.get_bdm(config, os)).to eq(first)
    end
  end
end
