# Encoding: UTF-8
# frozen_string_literal: true

require_relative "../../../spec_helper"
require_relative "../../../../lib/kitchen/driver/openstack/volume"

require "logger"
require "stringio"
require "rspec"
require "kitchen"
require "ohai"

describe Kitchen::Driver::Openstack::Volume do
  let(:os) do
    {
      openstack_username: "twilight",
      openstack_domain_id: "default",
      openstack_api_key: "sparkle",
      openstack_auth_url: "http:",
      openstack_project_name: "trixie",
      openstack_region: "syd",
      openstack_service_name: "the_service",
    }
  end
  let(:logger_io) { StringIO.new }
  let(:logger)    { Kitchen::Logger.new(logdev: logger_io) }
  describe "#volume" do
    let(:vol_driver) do
      described_class.new(logger)
    end

    it "creates a new block device connection" do
      allow(Fog::OpenStack::Volume).to receive(:new) { |arg| arg }
      expect(vol_driver.send(:volume, os)).to eq(os)
    end
  end
  describe "#create_volume" do
    let(:config) do
      {
        server_name: "applejack",
        block_device_mapping: {
          snapshot_id: "444",
          volume_size: "5",
          creation_timeout: "30",
          attach_timeout: 5,
        },
      }
    end

    let(:create_volume) do
      {
        body: { "volume" => { "id" => "555" } },
      }
    end

    let(:volume_model) do
      {
        id: "555",
        status: "ACTIVE",
        # wait_for: true
        # ready?: true
      }
    end

    let(:volume) do
      double(
        create_volume: create_volume,
        volumes: [volume_model]
      )
    end

    let(:wait_for) do
      {
        ready?: true,
        status: "ACTIVE",
      }
    end

    let(:vol_driver) do
      d = described_class.new(logger)
      allow(d).to receive(:volume).and_return(volume)
      allow(d).to receive(:volume_model).and_return(true)
      d
    end

    it "creates a volume" do
      # This seems like a hack
      # how would we do this on the volume_model instead?
      # This makes rspec work
      # but the vol_driver doesnt have these methods properties?
      allow(vol_driver).to receive(:status).and_return("ACTIVE")
      allow(config).to receive(:attach_timeout).and_return(5)
      allow(vol_driver).to receive(:ready?).and_return(true)
      allow(volume_model).to receive(:wait_for)
        .with(an_instance_of(String)).and_yield

      # allow(vol_driver).a
      expect(vol_driver.send(:create_volume, config, os)).to eq("555")
    end
  end

  describe "#get_bdm" do
    let(:config) do
      {
        block_device_mapping: {
          make_volue: true,
          snapshot_id: "333",
          volume_id: "555",
          volume_size: "5",
          volume_device_name: "vda",
          delete_on_termination: true,
          attach_timeout: 5,
        },
      }
    end

    let(:vol_driver) do
      d = described_class.new(logger)
      allow(d).to receive(:create_volume).and_return("555")
      d
    end

    it "returns the block device mapping config" do
      expects = config[:block_device_mapping]
      expects.delete_if { |k, _| k == :make_volume }
      expects.delete_if { |k, _| k == :snapshot_id }
      expect(vol_driver.send(:get_bdm, config, os)).to eq(expects)
    end
  end
end
