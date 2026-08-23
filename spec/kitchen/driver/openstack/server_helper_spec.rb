# frozen_string_literal: true

require "tempfile"

RSpec.describe Kitchen::Driver::Openstack::ServerHelper do
  include_context "with a configured driver"

  let(:images)  { [fog_resource(id: "111", name: "ubuntu-24.04"), fog_resource(id: "222", name: "centos-9")] }
  let(:flavors) { [fog_resource(id: "1", name: "m1.tiny"), fog_resource(id: "2", name: "m1.small")] }
  let(:networks) do
    [fog_resource(id: "net-1", name: "public"), fog_resource(id: "net-2", name: "private")]
  end

  let(:created_server) { fog_server }
  let(:servers)        { double("Fog servers collection", create: created_server) }
  let(:compute)        { fog_compute(servers: servers, images: images, flavors: flavors) }
  let(:net_service)    { fog_network(networks: double("networks", all: networks)) }

  before do
    allow(driver).to receive_messages(compute: compute, network: net_service)
  end

  describe "#create_server" do
    let(:config) do
      { server_name: "hello", image_id: "111", flavor_id: "1" }
    end

    it "returns whatever Nova created" do
      expect(driver.send(:create_server)).to be(created_server)
    end

    it "submits the mandatory attributes" do
      driver.send(:create_server)

      expect(servers).to have_received(:create).with(
        hash_including(name: "hello", image_ref: "111", flavor_ref: "1")
      )
    end

    it "passes the availability zone through" do
      config[:availability_zone] = "az1"

      driver.send(:create_server)

      expect(servers).to have_received(:create).with(hash_including(availability_zone: "az1"))
    end

    it "omits optional keys that are not configured" do
      driver.send(:create_server)

      expect(servers).to have_received(:create) do |server_def|
        expect(server_def.keys).to contain_exactly(:name, :image_ref, :flavor_ref, :availability_zone)
      end
    end

    describe "image and flavor resolution" do
      it "resolves image_ref by name" do
        config.delete(:image_id)
        config[:image_ref] = "centos-9"

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(image_ref: "222"))
      end

      it "resolves flavor_ref by name" do
        config.delete(:flavor_id)
        config[:flavor_ref] = "m1.small"

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(flavor_ref: "2"))
      end

      it "rejects both image_id and image_ref" do
        config[:image_ref] = "ubuntu-24.04"

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, "Cannot specify both image_ref and image_id")
      end

      it "rejects both flavor_id and flavor_ref" do
        config[:flavor_ref] = "m1.tiny"

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, "Cannot specify both flavor_ref and flavor_id")
      end

      it "fails when the image cannot be resolved" do
        config.delete(:image_id)
        config[:image_ref] = "no-such-image"

        expect { driver.send(:create_server) }.to raise_error(Kitchen::ActionFailed, "Image not found")
      end

      it "fails when the flavor cannot be resolved" do
        config.delete(:flavor_id)
        config[:flavor_ref] = "no-such-flavor"

        expect { driver.send(:create_server) }.to raise_error(Kitchen::ActionFailed, "Flavor not found")
      end
    end

    describe "networking" do
      it "builds nics from network_id" do
        config[:network_id] = "net-abc"

        driver.send(:create_server)

        expect(servers).to have_received(:create)
          .with(hash_including(nics: [{ "net_id" => "net-abc" }]))
      end

      it "builds nics from a list of network ids" do
        config[:network_id] = %w{net-abc net-def}

        driver.send(:create_server)

        expect(servers).to have_received(:create)
          .with(hash_including(nics: [{ "net_id" => "net-abc" }, { "net_id" => "net-def" }]))
      end

      it "resolves network_ref by name" do
        config[:network_ref] = "private"

        driver.send(:create_server)

        expect(servers).to have_received(:create)
          .with(hash_including(nics: [{ "net_id" => "net-2" }]))
      end

      it "resolves a list of network refs" do
        config[:network_ref] = %w{public private}

        driver.send(:create_server)

        expect(servers).to have_received(:create)
          .with(hash_including(nics: [{ "net_id" => "net-1" }, { "net_id" => "net-2" }]))
      end

      it "rejects both network_id and network_ref" do
        config[:network_id] = "net-abc"
        config[:network_ref] = "private"

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, "Cannot specify both network_ref and network_id")
      end

      it "fails when a network ref cannot be resolved" do
        config[:network_ref] = "no-such-net"

        expect { driver.send(:create_server) }.to raise_error(Kitchen::ActionFailed, "Network not found")
      end

      it "sends no nics when neither is configured" do
        driver.send(:create_server)

        expect(servers).to have_received(:create) { |sd| expect(sd).not_to have_key(:nics) }
      end
    end

    describe "block device mapping" do
      it "delegates to the volume helper" do
        config[:block_device_mapping] = { make_volume: true, volume_size: "5" }
        allow(driver).to receive(:get_bdm).and_return(volume_id: "vol-1")

        driver.send(:create_server)

        expect(servers).to have_received(:create)
          .with(hash_including(block_device_mapping: { volume_id: "vol-1" }))
      end

      # get_bdm is the only step in create_server that creates a resource, and
      # the id of a volume it creates lives only in the server_def that a later
      # raise discards -- so `kitchen destroy` would never see it. Local config
      # validation has to happen first.
      it "validates the rest of the config before creating a volume" do
        config[:block_device_mapping] = { make_volume: true, volume_size: "5" }
        config[:security_groups] = "default"
        allow(driver).to receive(:get_bdm).and_return(volume_id: "vol-1")

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, /security_groups config must be an array/)

        expect(driver).not_to have_received(:get_bdm)
      end

      it "validates the user_data path before creating a volume" do
        config[:block_device_mapping] = { make_volume: true, volume_size: "5" }
        config[:user_data] = "/nonexistent/cloud-init.yml"
        allow(driver).to receive(:get_bdm).and_return(volume_id: "vol-1")

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, /user_data file .* does not exist/)

        expect(driver).not_to have_received(:get_bdm)
      end

      it "detects the cloud_config/user_data conflict before creating a volume" do
        config[:block_device_mapping] = { make_volume: true, volume_size: "5" }
        config[:cloud_config] = { packages: %w{git} }
        # A readable file, so it is the conflict that raises and not the
        # existence check above it.
        config[:user_data] = "/tmp/whatever"
        allow(File).to receive(:exist?).with("/tmp/whatever").and_return(true)
        allow(File).to receive(:read).with("/tmp/whatever").and_return("#!/bin/sh")
        allow(driver).to receive(:get_bdm).and_return(volume_id: "vol-1")

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, "Cannot specify both cloud_config and user_data")

        expect(driver).not_to have_received(:get_bdm)
      end
    end

    describe "optional settings" do
      it "passes key_name through" do
        config[:key_name] = "my-key"

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(key_name: "my-key"))
      end

      it "passes metadata through" do
        config[:metadata] = { "owner" => "me" }

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(metadata: { "owner" => "me" }))
      end

      it "passes config_drive through" do
        config[:config_drive] = true

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(config_drive: true))
      end

      it "passes a list of security groups through" do
        config[:security_groups] = %w{default web}

        driver.send(:create_server)

        expect(servers).to have_received(:create).with(hash_including(security_groups: %w{default web}))
      end
    end

    describe "cloud_config" do
      it "renders it as a #cloud-config user_data document" do
        config[:cloud_config] = { packages: %w{htop} }

        driver.send(:create_server)

        expect(servers).to have_received(:create) do |server_def|
          expect(server_def[:user_data]).to start_with("#cloud-config\n")
          expect(server_def[:user_data]).to include("packages")
          expect(server_def[:user_data]).to include("htop")
        end
      end

      it "rejects being combined with user_data" do
        config[:cloud_config] = { packages: %w{htop} }
        config[:user_data] = "/tmp/whatever"
        allow(File).to receive(:exist?).with("/tmp/whatever").and_return(true)
        allow(File).to receive(:read).with("/tmp/whatever").and_return("#!/bin/sh")

        expect { driver.send(:create_server) }
          .to raise_error(Kitchen::ActionFailed, "Cannot specify both cloud_config and user_data")
      end
    end
  end

  describe "#optional_config" do
    let(:config) { {} }

    describe "user_data" do
      it "reads the file contents" do
        Tempfile.create("user_data") do |file|
          file.write("#!/bin/sh\necho hi\n")
          file.flush
          config[:user_data] = file.path

          expect(driver.send(:optional_config, :user_data)).to eq("#!/bin/sh\necho hi\n")
        end
      end

      # Regression: the old code returned nil for a missing file, so the server
      # booted without the user_data the operator asked for and nothing said so.
      it "fails when the file does not exist" do
        config[:user_data] = "/nonexistent/cloud-init.sh"

        expect { driver.send(:optional_config, :user_data) }
          .to raise_error(Kitchen::ActionFailed, "The user_data file </nonexistent/cloud-init.sh> does not exist")
      end
    end

    describe "security_groups" do
      it "passes a list through" do
        config[:security_groups] = %w{default}

        expect(driver.send(:optional_config, :security_groups)).to eq(%w{default})
      end

      # Regression: a bare string used to be dropped silently, booting the
      # server into the default security group instead of the requested one.
      it "fails on a bare string rather than dropping it" do
        config[:security_groups] = "default"

        expect { driver.send(:optional_config, :security_groups) }
          .to raise_error(Kitchen::ActionFailed, /security_groups config must be an array/)
      end
    end

    it "returns anything else verbatim" do
      config[:key_name] = "my-key"

      expect(driver.send(:optional_config, :key_name)).to eq("my-key")
    end
  end

  describe "#find_matching" do
    let(:collection) do
      [
        fog_resource(id: "111", name: "ubuntu-24.04"),
        fog_resource(id: "222", name: "ubuntu-22.04"),
        fog_resource(id: "333", name: "centos-9"),
      ]
    end

    it "matches an exact id" do
      expect(driver.send(:find_matching, collection, "222").name).to eq("ubuntu-22.04")
    end

    it "matches an exact name" do
      expect(driver.send(:find_matching, collection, "centos-9").id).to eq("333")
    end

    it "prefers an id match over a name match" do
      ambiguous = [fog_resource(id: "aaa", name: "bbb"), fog_resource(id: "bbb", name: "ccc")]

      expect(driver.send(:find_matching, ambiguous, "bbb").id).to eq("bbb")
    end

    it "matches a regex against the name" do
      expect(driver.send(:find_matching, collection, "/^ubuntu-22/").id).to eq("222")
    end

    it "returns the first regex match when several names match" do
      expect(driver.send(:find_matching, collection, "/^ubuntu/").id).to eq("111")
    end

    it "does not treat a regex ref as an id" do
      expect(driver.send(:find_matching, collection, "/nope/")).to be_nil
    end

    it "returns nil when nothing matches" do
      expect(driver.send(:find_matching, collection, "debian")).to be_nil
    end

    it "returns nil for an empty collection" do
      expect(driver.send(:find_matching, [], "anything")).to be_nil
    end

    # Nova hands back integer ids for flavors on some deployments, while
    # kitchen.yml always carries strings.
    it "matches an integer id against a string ref" do
      numeric = [fog_resource(id: 1, name: "m1.tiny")]

      expect(driver.send(:find_matching, numeric, "1").name).to eq("m1.tiny")
    end

    it "accepts a non-string ref" do
      numeric = [fog_resource(id: "1", name: "m1.tiny")]

      expect(driver.send(:find_matching, numeric, 1).name).to eq("m1.tiny")
    end

    # Unnamed networks are legal in Neutron, so a regex search has to walk past
    # them to reach a named match rather than stopping at the first entry.
    it "skips unnamed resources when matching a regex" do
      unnamed = [fog_resource(id: "111", name: nil), fog_resource(id: "222", name: "ubuntu-24.04")]

      expect(driver.send(:find_matching, unnamed, "/ubuntu/").id).to eq("222")
    end

    # The `single.name &&` guard is what makes the above true for *any* regex,
    # not just one that happens not to match "". Coercing a nil name with
    # `to_s` instead would hand an empty string to the regex, and a pattern
    # like /.*/ matches that -- silently selecting the unnamed resource.
    it "skips unnamed resources even for a regex that matches an empty string" do
      unnamed = [fog_resource(id: "111", name: nil), fog_resource(id: "222", name: "ubuntu-24.04")]

      expect(driver.send(:find_matching, unnamed, "/.*/").id).to eq("222")
    end
  end

  describe "#find_image" do
    it "logs which image it selected" do
      driver.send(:find_image, "ubuntu-24.04")

      expect(logged_output.string).to include("Selected image: 111 ubuntu-24.04")
    end
  end

  describe "#find_flavor" do
    it "logs which flavor it selected" do
      driver.send(:find_flavor, "m1.tiny")

      expect(logged_output.string).to include("Selected flavor: 1 m1.tiny")
    end
  end

  describe "#find_network" do
    it "logs which network it selected" do
      driver.send(:find_network, "public")

      expect(logged_output.string).to include("Selected net: net-1 public")
    end
  end
end
