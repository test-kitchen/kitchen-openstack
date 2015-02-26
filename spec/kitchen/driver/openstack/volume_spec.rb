# Encoding: UTF-8

require_relative '../../../spec_helper'
require_relative '../../../../lib/kitchen/driver/openstack/volume'

require 'logger'
require 'stringio'
require 'rspec'
require 'kitchen'
require 'ohai'

describe Kitchen::Driver::Openstack::Volume do
  let(:os) do
    {
      openstack_username: 'twilight',
      openstack_api_key: 'sparkle',
      openstack_auth_url: 'http:',
      openstack_tenant: 'trixie',
      openstack_region: 'syd',
      openstack_service_name: 'the_service'
    }
  end

  describe '#volume' do
    let(:vol_driver) do
      described_class.new
    end

    it 'creates a new block device connection' do
      allow(Fog::Volume).to receive(:new) { |arg| arg }
      expect(vol_driver.send(:volume, os)).to eq(os)
    end
  end

  describe '#volume_ready?' do
    let(:volume_details) do
      {
        body: { 'volume' => { 'status' => 'available' } }
      }
    end

    let(:volume) do
      double(
        get_volume_details: volume_details
      )
    end

    let(:vol_driver) do
      d = described_class.new
      allow(d).to receive(:volume).and_return(volume)
      d
    end

    it 'checks if the volume is ready' do
      expect(vol_driver.send(:volume_ready?, '333', os)).to eq(true)
    end
  end

  describe '#create_volume' do
    let(:config) do
      {
        server_name: 'applejack',
        block_device_mapping: {
          snapshot_id: '444',
          volume_size: '5'
        }
      }
    end

    let(:create_volume) do
      {
        body: { 'volume' => { 'id' => '555' } }
      }
    end

    let(:volume) do
      double(
        create_volume: create_volume
      )
    end

    let(:vol_driver) do
      d = described_class.new
      allow(d).to receive(:volume).and_return(volume)
      allow(d).to receive(:volume_ready?).and_return(true)
      d
    end

    it 'creates a volume' do
      expect(vol_driver.send(:create_volume, config, os)).to eq('555')
    end
  end

  describe '#get_bdm' do
    let(:config) do
      {
        block_device_mapping: {
          make_volue: true,
          snapshot_id: '333',
          volume_id: '555',
          volume_size: '5',
          volume_device_name: 'vda',
          delete_on_termination: true
        }
      }
    end

    let(:vol_driver) do
      d = described_class.new
      allow(d).to receive(:create_volume).and_return('555')
      d
    end

    it 'returns the block device mapping config' do
      expects = config[:block_device_mapping]
      expects.delete_if { |k, _| k == :make_volume }
      expects.delete_if { |k, _| k == :snapshot_id }
      expect(vol_driver.send(:get_bdm, config, os)).to eq(expects)
    end
  end
end
