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

require 'logger'
require 'stringio'
require 'rspec'
require 'kitchen'
require_relative '../../spec_helper'

describe Kitchen::Driver::Openstack do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { Hash.new }
  let(:state) { Hash.new }

  let(:instance) do
    stub(:name => 'potatoes', :logger => logger, :to_str => 'instance')
  end

  let(:driver) do
    d = Kitchen::Driver::Openstack.new(config)
    d.instance = instance
    d
  end

  describe '#initialize'do
    context 'default options' do
      it 'defaults to local user\'s SSH public key' do
        expect(driver[:public_key_path]).to eq(File.expand_path(
          '~/.ssh/id_dsa.pub'))
      end

      it 'defaults to SSH with root user on port 22' do
        expect(driver[:username]).to eq('root')
        expect(driver[:port]).to eq('22')
      end

      it 'defaults to no server name' do
        expect(driver[:name]).to eq(nil)
      end

      it 'defaults to no tenant' do
        expect(driver[:openstack_tenant]).to eq(nil)
      end

      it 'defaults to no region' do
        expect(driver[:openstack_region]).to eq(nil)
      end

      it 'defaults to no service name' do
        expect(driver[:openstack_service_name]).to eq(nil)
      end
    end

    context 'overridden options' do
      let(:config) do
        {
          :image_ref => '22',
          :flavor_ref => '33',
          :public_key_path => '/tmp',
          :username => 'admin',
          :port => '2222',
          :name => 'puppy',
          :openstack_tenant => 'that_one',
          :openstack_region => 'atlantis',
          :openstack_service_name => 'the_service',
          :ssh_key => '/path/to/id_rsa'
        }
      end

      it 'uses all the overridden options' do
        drv = driver
        config.each do |k, v|
          expect(drv[k]).to eq(v)
        end
      end

      it 'SSH with user-specified private key' do
        expect(driver[:ssh_key]).to eq('/path/to/id_rsa')
      end
    end
  end

  describe '#create' do
    let(:server) do
      stub(:id => 'test123', :wait_for => true,
        :public_ip_address => '1.2.3.4')
    end
    let(:driver) do
      d = Kitchen::Driver::Openstack.new(config)
      d.instance = instance
      d.stub(:generate_name).with('potatoes').and_return('a_monkey!')
      d.stub(:create_server).and_return(server)
      d.stub(:wait_for_sshd).with('1.2.3.4').and_return(true)
      d.stub(:get_ip).and_return('1.2.3.4')
      d.stub(:do_ssh_setup).and_return(true)
      d
    end

    context 'required options provided' do
      let(:config) do
        {
          :openstack_username => 'hello',
          :openstack_api_key => 'world',
          :openstack_auth_url => 'http:',
          :openstack_tenant => 'www'
        }
      end

      it 'generates a server name in the absence of one' do
        driver.create(state)
        expect(driver[:name]).to eq('a_monkey!')
      end

      it 'gets a proper server ID' do
        driver.create(state)
        expect(state[:server_id]).to eq('test123')
      end

      it 'gets a proper hostname (IP)' do
        driver.create(state)
        expect(state[:hostname]).to eq('1.2.3.4')
      end

      it 'does not disable SSL validation' do
        driver.should_not_receive(:disable_ssl_validation)
        driver.create(state)
      end
    end

    context 'SSL validation disabled' do
      let(:config) { { :disable_ssl_validation => true } }

      it 'disables SSL cert validation' do
        driver.should_receive(:disable_ssl_validation)
        driver.create(state)
      end
    end
  end

  describe '#destroy' do
    let(:server_id) { '12345' }
    let(:hostname) { 'example.com' }
    let(:state) { { :server_id => server_id, :hostname => hostname } }
    let(:server) { stub(:nil? => false, :destroy => true) }
    let(:servers) { stub(:get => server) }
    let(:compute) { stub(:servers => servers) }

    let(:driver) do
      d = Kitchen::Driver::Openstack.new(config)
      d.instance = instance
      d.stub(:compute).and_return(compute)
      d
    end

    context 'a live server that needs to be destroyed' do
      it 'destroys the server' do
        state.should_receive(:delete).with(:server_id)
        state.should_receive(:delete).with(:hostname)
        driver.destroy(state)
      end

      it 'does not disable SSL cert validation' do
        driver.should_not_receive(:disable_ssl_validation)
        driver.destroy(state)
      end
    end

    context 'no server ID present' do
      let(:state) { Hash.new }

      it 'does nothing' do
        driver.stub(:compute)
        driver.should_not_receive(:compute)
        state.should_not_receive(:delete)
        driver.destroy(state)
      end
    end

    context 'a server that was already destroyed' do
      let(:servers) do
        s = double('servers')
        s.stub(:get).with('12345').and_return(nil)
        s
      end
      let(:compute) { stub(:servers => servers) }
      let(:driver) do
        d = Kitchen::Driver::Openstack.new(config)
        d.instance = instance
        d.stub(:compute).and_return(compute)
        d
      end

      it 'does not try to destroy the server again' do
        allow_message_expectations_on_nil
        driver.destroy(state)
      end
    end

    context 'SSL validation disabled' do
      let(:config) { { :disable_ssl_validation => true } }

      it 'disables SSL cert validation' do
        driver.should_receive(:disable_ssl_validation)
        driver.destroy(state)
      end
    end
  end

  describe '#compute' do
    let(:config) do
      {
        :openstack_username => 'monkey',
        :openstack_api_key => 'potato',
        :openstack_auth_url => 'http:',
        :openstack_tenant => 'link',
        :openstack_region => 'ord',
        :openstack_service_name => 'the_service'
      }
    end

    context 'all requirements provided' do
      it 'creates a new compute connection' do
        Fog::Compute.stub(:new) { |arg| arg }
        res = config.merge({ :provider => 'OpenStack' })
        expect(driver.send(:compute)).to eq(res)
      end
    end

    context 'only an API key provided' do
      let(:config) { { :openstack_api_key => '1234' } }

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end

    context 'only a username provided' do
      let(:config) { { :openstack_username => 'monkey' } }

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#create_server' do
    let(:config) do
      {
        :name => 'hello',
        :image_ref => 'there',
        :flavor_ref => 'captain',
        :public_key_path => 'tarpals'
      }
    end
    let(:servers) do
      s = double('servers')
      s.stub(:create) { |arg| arg }
      s
    end
    let(:compute) { stub(:servers => servers) }
    let(:driver) do
      d = Kitchen::Driver::Openstack.new(config)
      d.instance = instance
      d.stub(:compute).and_return(compute)
      d
    end

    context 'a default config' do
      before(:each) { @config = config.dup }

      it 'creates the server using a compute connection' do
        expect(driver.send(:create_server)).to eq(@config)
      end
    end

    context 'a provided public key path' do
      let(:config) do
        {
          :name => 'hello',
          :image_ref => 'there',
          :flavor_ref => 'captain',
          :public_key_path => 'tarpals'
        }
      end
      before(:each) { @config = config.dup }

      it 'passes that public key path to Fog' do
        expect(driver.send(:create_server)).to eq(@config)
      end
    end

    context 'a provided key name' do
      let(:config) do
        {
          :name => 'hello',
          :image_ref => 'there',
          :flavor_ref => 'captain',
          :public_key_path => 'montgomery',
          :key_name => 'tarpals'
        }
      end
      before(:each) { @config = config.dup }

      it 'passes that key name to Fog' do
        expect(driver.send(:create_server)).to eq(@config)
      end
    end
  end

  describe '#generate_name' do
    before(:each) do
      Etc.stub(:getlogin).and_return('user')
      Socket.stub(:gethostname).and_return('host')
    end

    it 'generates a name' do
      expect(driver.send(:generate_name, 'monkey')).to match(
        /^monkey-user-host-/)
    end
  end

  describe '#get_ip' do
    let(:addresses) { { 'public' => [], 'private' => [] } }
    let(:server) { stub(:addresses => addresses) }

    context 'both public and private IPs' do
      let(:addresses) do
        {
          'public' => [
            { 'addr' => '1.2.3.4' },
            { 'addr' => '1.2.3.5' }
          ],
          'private' => [
            { 'addr' => '5.5.5.5' },
            { 'addr' => '6.6.6.6' }
          ]
        }
      end

      it 'returns a public IP' do
        expect(driver.send(:get_ip, server)).to eq('1.2.3.4')
      end
    end

    context 'only private IPs' do
      let(:addresses) do
        {
          'private' => [
            { 'addr' => '5.5.5.5' },
            { 'addr' => '6.6.6.6' }
          ]
        }
      end
      it 'returns a private IP' do
        expect(driver.send(:get_ip, server)).to eq('5.5.5.5')
      end
    end
  end

  describe '#do_ssh_setup' do
    let(:server) { stub(:password => 'aloha') }
    let(:state) { { :hostname => 'host' } }
    let(:read) { stub(:read => 'a_key') }
    let(:ssh) do
      s = double('ssh')
      s.stub(:run) { |args| args }
      s
    end

    it 'opens an SSH session to the server' do
      Fog::SSH.stub(:new).with('host', 'root',
        { :password => 'aloha' }).and_return(ssh)
      driver.stub(:open).with(File.expand_path(
        '~/.ssh/id_dsa.pub')).and_return(read)
      read.stub(:read).and_return('a_key')
      res = driver.send(:do_ssh_setup, state, config, server)
      expected = [
        'mkdir .ssh',
        'echo "a_key" >> ~/.ssh/authorized_keys',
        'passwd -l root'
      ]
      expect(res).to eq(expected)
    end
  end

  describe '#disable_ssl_validation' do
    it 'turns off Excon SSL cert validation' do
      expect(driver.send(:disable_ssl_validation)).to eq(false)
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
