# frozen_string_literal: true

RSpec.describe Kitchen::Driver::Openstack::Config do
  include_context "with a configured driver"

  let(:login)    { "user" }
  let(:hostname) { "host" }

  # Both lookups hit the host machine, so pin them or the assertions below
  # depend on whoever is running the suite.
  before do
    allow(Etc).to receive(:getpwuid).and_return(Struct.new(:name).new(login))
    allow(Etc).to receive(:getlogin).and_return(login)
    allow(Socket).to receive(:gethostname).and_return(hostname)
  end

  describe "#config_server_name" do
    context "when the user configured a server name" do
      let(:config) { { server_name: "puppy" } }

      it "leaves it alone" do
        driver.send(:config_server_name)

        expect(driver[:server_name]).to eq("puppy")
      end

      it "does not consult the prefix" do
        config[:server_name_prefix] = "parsnip"

        driver.send(:config_server_name)

        expect(driver[:server_name]).to eq("puppy")
      end
    end

    context "when only a prefix is configured" do
      let(:config) { { server_name_prefix: "parsnip" } }

      it "builds the name from the prefix" do
        driver.send(:config_server_name)

        expect(driver[:server_name]).to match(/\Aparsnip-[a-z]{8}\z/)
      end
    end

    context "when nothing is configured" do
      it "generates a full default name" do
        driver.send(:config_server_name)

        expect(driver[:server_name]).to match(/\Apotatoes-user-host-[a-z0-9]{7}\z/)
      end
    end
  end

  describe "#default_name" do
    it "joins instance, user, host and a random suffix" do
      expect(driver.send(:default_name)).to match(/\Apotatoes-user-host-[a-z0-9]{7}\z/)
    end

    it "returns a different name on each call" do
      expect(driver.send(:default_name)).not_to eq(driver.send(:default_name))
    end

    context "with a long hostname" do
      let(:hostname) { "ab.c" * 20 }

      it "stays within the OpenStack name limit" do
        expect(driver.send(:default_name).length)
          .to be <= Kitchen::Driver::Openstack::Config::MAX_SERVER_NAME_LENGTH
      end
    end

    context "with a long instance name, user and host" do
      let(:instance_name) { "a" * 40 }
      let(:login)         { "b" * 40 }
      let(:hostname)      { "c" * 40 }

      it "stays within the OpenStack name limit" do
        expect(driver.send(:default_name).length)
          .to be <= Kitchen::Driver::Openstack::Config::MAX_SERVER_NAME_LENGTH
      end

      # The longest name the generator can produce is exactly the limit, which
      # is what makes MAX_SERVER_NAME_LENGTH a real constraint rather than a
      # comment: the per-component budgets are derived from it.
      it "uses the whole budget when every component is oversized" do
        expect(driver.send(:default_name).length)
          .to eq(Kitchen::Driver::Openstack::Config::MAX_SERVER_NAME_LENGTH)
      end

      it "truncates each component to its documented budget" do
        config_mod = Kitchen::Driver::Openstack::Config
        instance_part, user_part, host_part, random_part = driver.send(:default_name).split("-")

        expect(instance_part.length).to eq(config_mod::NAME_INSTANCE_LENGTH)
        expect(user_part.length).to eq(config_mod::NAME_USERNAME_LENGTH)
        expect(host_part.length).to eq(config_mod::NAME_HOSTNAME_LENGTH)
        expect(random_part.length).to eq(config_mod::NAME_RANDOM_LENGTH)
      end
    end

    context "with punctuation in the names" do
      let(:login)         { "some.u-se-r" }
      let(:hostname)      { "a.host-name" }
      let(:instance_name) { "a.instance-name" }

      it "strips characters OpenStack rejects in server names" do
        expect(driver.send(:default_name)).not_to include(".")
      end

      it "leaves exactly the three separators" do
        expect(driver.send(:default_name).count("-")).to eq(3)
      end
    end

    # Regression: the old code assumed Etc.getpwuid returns nil for an unknown
    # uid. It raises, so this path used to blow up inside containers.
    context "when the uid has no passwd entry" do
      before { allow(Etc).to receive(:getpwuid).and_raise(ArgumentError, "can't find user for 501") }

      it "falls back to the login name" do
        expect(driver.send(:default_name)).to match(/\Apotatoes-user-host-/)
      end

      context "and there is no login name either" do
        before { allow(Etc).to receive(:getlogin).and_return(nil) }

        it "substitutes a placeholder rather than raising" do
          expect(driver.send(:default_name)).to match(/\Apotatoes-nologin-host-/)
        end
      end
    end

    context "when getpwuid returns nil" do
      before { allow(Etc).to receive_messages(getpwuid: nil, getlogin: nil) }

      it "substitutes a placeholder" do
        expect(driver.send(:default_name)).to match(/\Apotatoes-nologin-host-/)
      end
    end
  end

  describe "#server_name_prefix" do
    it "appends a random lowercase suffix" do
      expect(driver.send(:server_name_prefix, "parsnip")).to match(/\Aparsnip-[a-z]{8}\z/)
    end

    it "returns a different name on each call" do
      expect(driver.send(:server_name_prefix, "parsnip"))
        .not_to eq(driver.send(:server_name_prefix, "parsnip"))
    end

    it "strips characters OpenStack rejects" do
      expect(driver.send(:server_name_prefix, "pars.nip-x")).to match(/\Aparsnipx-[a-z]{8}\z/)
    end

    context "with a prefix over the length budget" do
      let(:long_prefix) { "a" * 70 }

      it "stays within the OpenStack name limit" do
        expect(driver.send(:server_name_prefix, long_prefix).length)
          .to be <= Kitchen::Driver::Openstack::Config::MAX_SERVER_NAME_LENGTH
      end

      it "warns the user it truncated" do
        driver.send(:server_name_prefix, long_prefix)

        expect(logged_output.string).to match(/prefix too long/i)
      end
    end

    context "with a prefix that is empty once stripped" do
      it "falls back to a fully generated name" do
        expect(driver.send(:server_name_prefix, "...")).to match(/\Apotatoes-user-host-/)
      end

      it "warns the user" do
        driver.send(:server_name_prefix, "...")

        expect(logged_output.string).to match(/prefix empty or invalid/i)
      end

      it "handles an entirely empty prefix" do
        expect(driver.send(:server_name_prefix, "")).to match(/\Apotatoes-user-host-/)
      end
    end

    # Regression: the old implementation called gsub! on the argument, which
    # rewrote config[:server_name_prefix] in place and raised FrozenError when
    # the prefix came from a frozen string literal.
    it "does not mutate the string it was given" do
      prefix = +"pars.nip"

      driver.send(:server_name_prefix, prefix)

      expect(prefix).to eq("pars.nip")
    end

    it "accepts a frozen prefix" do
      expect { driver.send(:server_name_prefix, "pars.nip".freeze) }.not_to raise_error
    end

    it "leaves the configured prefix intact after config_server_name" do
      config[:server_name_prefix] = +"pars.nip"

      driver.send(:config_server_name)

      expect(driver[:server_name_prefix]).to eq("pars.nip")
    end
  end
end
