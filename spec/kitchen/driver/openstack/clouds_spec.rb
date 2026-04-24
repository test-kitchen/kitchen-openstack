# frozen_string_literal: true

require_relative "../../../spec_helper"
require_relative "../../../../lib/kitchen/driver/openstack"

require "logger"
require "stringio" unless defined?(StringIO)
require "rspec"
require "kitchen"
require "kitchen/driver/openstack"
require "kitchen/provisioner/dummy"
require "kitchen/transport/dummy"
require "kitchen/verifier/dummy"

describe Kitchen::Driver::Openstack do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { {} }
  let(:instance_name) { "potatoes" }
  let(:transport) { Kitchen::Transport::Dummy.new }
  let(:platform) { Kitchen::Platform.new(name: "fake_platform") }
  let(:driver) { described_class.new(config) }

  let(:instance) do
    double(
      name: instance_name,
      transport: transport,
      logger: logger,
      platform: platform,
      to_str: "instance"
    )
  end

  before(:each) do
    allow_any_instance_of(described_class).to receive(:instance)
      .and_return(instance)
    allow(File).to receive(:exist?).and_call_original
  end

  let(:clouds_yaml_content) do
    {
      "clouds" => {
        "mycloud" => {
          "auth" => {
            "auth_url" => "https://keystone.example.com:5000/v3",
            "username" => "testuser",
            "password" => "testpass",
            "project_name" => "testproject",
            "user_domain_name" => "Default",
            "project_domain_name" => "Default",
            "domain_id" => "default",
          },
          "region_name" => "RegionOne",
          "interface" => "public",
          "identity_api_version" => "3",
        },
        "minimal" => {
          "auth" => {
            "auth_url" => "https://minimal.example.com:5000/v3",
            "username" => "minuser",
            "password" => "minpass",
            "domain_id" => "default",
          },
        },
        "appcred" => {
          "auth" => {
            "auth_url" => "https://appcred.example.com:5000/v3",
            "application_credential_id" => "abc123",
            "application_credential_secret" => "secret456",
            "domain_id" => "default",
          },
          "auth_type" => "v3applicationcredential",
        },
        "sslcloud" => {
          "auth" => {
            "auth_url" => "https://ssl.example.com:5000/v3",
            "username" => "ssluser",
            "password" => "sslpass",
            "domain_id" => "default",
          },
          "verify" => false,
          "cacert" => "/path/to/ca.crt",
        },
      },
    }
  end

  let(:secure_yaml_content) do
    {
      "clouds" => {
        "mycloud" => {
          "auth" => {
            "password" => "secure_password_override",
          },
        },
      },
    }
  end

  describe "#cloud_name" do
    context "when openstack_cloud is set in config" do
      let(:config) { { openstack_cloud: "mycloud" } }

      it "returns the config value" do
        expect(driver.send(:cloud_name)).to eq("mycloud")
      end
    end

    context "when OS_CLOUD env var is set" do
      before { allow(ENV).to receive(:[]).and_call_original }
      before { allow(ENV).to receive(:[]).with("OS_CLOUD").and_return("envcloud") }

      it "returns the env var value" do
        expect(driver.send(:cloud_name)).to eq("envcloud")
      end
    end

    context "when openstack_cloud config takes precedence over OS_CLOUD" do
      let(:config) { { openstack_cloud: "configcloud" } }

      before { allow(ENV).to receive(:[]).and_call_original }
      before { allow(ENV).to receive(:[]).with("OS_CLOUD").and_return("envcloud") }

      it "returns the config value" do
        expect(driver.send(:cloud_name)).to eq("configcloud")
      end
    end

    context "when neither is set" do
      before { allow(ENV).to receive(:[]).and_call_original }
      before { allow(ENV).to receive(:[]).with("OS_CLOUD").and_return(nil) }

      it "returns nil" do
        expect(driver.send(:cloud_name)).to be_nil
      end
    end
  end

  describe "#load_clouds_config" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLIENT_SECURE_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLOUD").and_return(nil)
    end

    context "when no cloud name is configured" do
      it "returns an empty hash" do
        expect(driver.send(:load_clouds_config)).to eq({})
      end
    end

    context "when a cloud name is set and clouds.yaml exists" do
      let(:config) { { openstack_cloud: "mycloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "returns translated fog config" do
        result = driver.send(:load_clouds_config)
        expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(result[:openstack_username]).to eq("testuser")
        expect(result[:openstack_api_key]).to eq("testpass")
        expect(result[:openstack_project_name]).to eq("testproject")
        expect(result[:openstack_user_domain]).to eq("Default")
        expect(result[:openstack_project_domain]).to eq("Default")
        expect(result[:openstack_domain_id]).to eq("default")
        expect(result[:openstack_region]).to eq("RegionOne")
        expect(result[:openstack_endpoint_type]).to eq("public")
        expect(result[:openstack_identity_api_version]).to eq("3")
      end
    end

    context "when secure.yaml provides password override" do
      let(:config) { { openstack_cloud: "mycloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "secure.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "secure.yaml"))
          .and_return(YAML.dump(secure_yaml_content))
      end

      it "merges secure.yaml values over clouds.yaml" do
        result = driver.send(:load_clouds_config)
        expect(result[:openstack_api_key]).to eq("secure_password_override")
        expect(result[:openstack_username]).to eq("testuser")
      end
    end

    context "when OS_CLIENT_CONFIG_FILE is set" do
      let(:config) { { openstack_cloud: "mycloud" } }
      let(:custom_path) { "/custom/path/clouds.yaml" }

      before do
        allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return(custom_path)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with(custom_path).and_return(true)
        allow(File).to receive(:read)
          .with(custom_path)
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "uses the custom path" do
        result = driver.send(:load_clouds_config)
        expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
      end
    end

    context "when clouds_yaml_path config is set" do
      let(:config) { { openstack_cloud: "mycloud", clouds_yaml_path: "/my/clouds.yaml" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with("/my/clouds.yaml").and_return(true)
        allow(File).to receive(:read)
          .with("/my/clouds.yaml")
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "uses the configured path" do
        result = driver.send(:load_clouds_config)
        expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
      end
    end

    context "when cloud entry does not exist in clouds.yaml" do
      let(:config) { { openstack_cloud: "nonexistent" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "returns an empty hash" do
        expect(driver.send(:load_clouds_config)).to eq({})
      end
    end

    context "with application credential auth" do
      let(:config) { { openstack_cloud: "appcred" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "maps application credential fields" do
        result = driver.send(:load_clouds_config)
        expect(result[:openstack_application_credential_id]).to eq("abc123")
        expect(result[:openstack_application_credential_secret]).to eq("secret456")
      end
    end

    context "with SSL settings" do
      let(:config) { { openstack_cloud: "sslcloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "maps SSL settings" do
        result = driver.send(:load_clouds_config)
        expect(result[:ssl_verify_peer]).to eq(false)
        expect(result[:ssl_ca_file]).to eq("/path/to/ca.crt")
      end
    end
  end

  describe "#clouds_yaml_search_paths" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return(nil)
    end

    context "with no env var or config path" do
      it "returns standard search paths" do
        paths = driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")
        expect(paths).to include(File.join(Dir.pwd, "clouds.yaml"))
        expect(paths).to include(File.join(Dir.home, ".config", "openstack", "clouds.yaml"))
        expect(paths).to include("/etc/openstack/clouds.yaml")
      end
    end

    context "with env var set" do
      before do
        allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return("/custom/clouds.yaml")
      end

      it "prepends the env var path" do
        paths = driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")
        expect(paths.first).to eq("/custom/clouds.yaml")
      end
    end

    context "with clouds_yaml_path config" do
      let(:config) { { clouds_yaml_path: "/configured/clouds.yaml" } }

      it "includes the configured path" do
        paths = driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")
        expect(paths).to include("/configured/clouds.yaml")
      end

      it "does not include config path for secure.yaml" do
        paths = driver.send(:clouds_yaml_search_paths, "secure.yaml", "OS_CLIENT_SECURE_FILE")
        expect(paths).not_to include("/configured/clouds.yaml")
      end
    end
  end

  describe "#translate_cloud_config" do
    it "maps all auth keys correctly" do
      cloud = {
        "auth" => {
          "auth_url" => "http://example.com:5000/v3",
          "username" => "user",
          "password" => "pass",
          "project_name" => "proj",
          "project_id" => "proj-id",
          "user_domain_name" => "UDN",
          "user_domain_id" => "udi",
          "project_domain_name" => "PDN",
          "project_domain_id" => "pdi",
          "domain_id" => "did",
          "domain_name" => "dname",
          "application_credential_id" => "acid",
          "application_credential_secret" => "acs",
        },
        "region_name" => "Region1",
        "interface" => "internal",
        "identity_api_version" => "3",
        "verify" => true,
        "cacert" => "/ca.pem",
      }

      result = driver.send(:translate_cloud_config, cloud)
      expect(result[:openstack_auth_url]).to eq("http://example.com:5000/v3")
      expect(result[:openstack_username]).to eq("user")
      expect(result[:openstack_api_key]).to eq("pass")
      expect(result[:openstack_project_name]).to eq("proj")
      expect(result[:openstack_project_id]).to eq("proj-id")
      expect(result[:openstack_user_domain]).to eq("UDN")
      expect(result[:openstack_user_domain_id]).to eq("udi")
      expect(result[:openstack_project_domain]).to eq("PDN")
      expect(result[:openstack_project_domain_id]).to eq("pdi")
      expect(result[:openstack_domain_id]).to eq("did")
      expect(result[:openstack_domain_name]).to eq("dname")
      expect(result[:openstack_application_credential_id]).to eq("acid")
      expect(result[:openstack_application_credential_secret]).to eq("acs")
      expect(result[:openstack_region]).to eq("Region1")
      expect(result[:openstack_endpoint_type]).to eq("internal")
      expect(result[:openstack_identity_api_version]).to eq("3")
      expect(result[:ssl_verify_peer]).to eq(true)
      expect(result[:ssl_ca_file]).to eq("/ca.pem")
    end

    it "handles empty auth section" do
      result = driver.send(:translate_cloud_config, {})
      expect(result).to eq({})
    end

    it "coerces non-string scalar values for fog string config keys" do
      cloud = {
        "auth" => {
          "project_id" => 12_345,
          "domain_id" => 9,
        },
        "identity_api_version" => 3,
      }

      result = driver.send(:translate_cloud_config, cloud)
      expect(result[:openstack_project_id]).to eq("12345")
      expect(result[:openstack_domain_id]).to eq("9")
      expect(result[:openstack_identity_api_version]).to eq("3")
    end
  end

  describe "#deep_merge" do
    it "deep merges nested hashes" do
      base = { "auth" => { "username" => "user", "password" => "base_pass" }, "region" => "r1" }
      override = { "auth" => { "password" => "override_pass" } }
      result = driver.send(:deep_merge, base, override)
      expect(result["auth"]["username"]).to eq("user")
      expect(result["auth"]["password"]).to eq("override_pass")
      expect(result["region"]).to eq("r1")
    end

    it "does not mutate the original hashes" do
      base = { "auth" => { "password" => "old" } }
      override = { "auth" => { "password" => "new" } }
      driver.send(:deep_merge, base, override)
      expect(base["auth"]["password"]).to eq("old")
    end
  end

  describe "#load_env_vars" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      Kitchen::Driver::Openstack::Clouds::ENV_VAR_MAP.each_key do |var|
        allow(ENV).to receive(:[]).with(var).and_return(nil)
      end
    end

    context "when no OS_* env vars are set" do
      it "returns an empty hash" do
        expect(driver.send(:load_env_vars)).to eq({})
      end
    end

    context "when OS_AUTH_URL and OS_USERNAME are set" do
      before do
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("https://env.example.com:5000/v3")
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
      end

      it "maps them to fog config keys" do
        result = driver.send(:load_env_vars)
        expect(result[:openstack_auth_url]).to eq("https://env.example.com:5000/v3")
        expect(result[:openstack_username]).to eq("envuser")
      end
    end

    context "when all standard OS_* env vars are set" do
      before do
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("https://env.example.com:5000/v3")
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
        allow(ENV).to receive(:[]).with("OS_PASSWORD").and_return("envpass")
        allow(ENV).to receive(:[]).with("OS_PROJECT_NAME").and_return("envproject")
        allow(ENV).to receive(:[]).with("OS_USER_DOMAIN_NAME").and_return("EnvDomain")
        allow(ENV).to receive(:[]).with("OS_PROJECT_DOMAIN_NAME").and_return("EnvProjDomain")
        allow(ENV).to receive(:[]).with("OS_DOMAIN_ID").and_return("envdomid")
        allow(ENV).to receive(:[]).with("OS_REGION_NAME").and_return("EnvRegion")
        allow(ENV).to receive(:[]).with("OS_IDENTITY_API_VERSION").and_return("3")
      end

      it "maps all env vars to fog config keys" do
        result = driver.send(:load_env_vars)
        expect(result[:openstack_auth_url]).to eq("https://env.example.com:5000/v3")
        expect(result[:openstack_username]).to eq("envuser")
        expect(result[:openstack_api_key]).to eq("envpass")
        expect(result[:openstack_project_name]).to eq("envproject")
        expect(result[:openstack_user_domain]).to eq("EnvDomain")
        expect(result[:openstack_project_domain]).to eq("EnvProjDomain")
        expect(result[:openstack_domain_id]).to eq("envdomid")
        expect(result[:openstack_region]).to eq("EnvRegion")
        expect(result[:openstack_identity_api_version]).to eq("3")
      end
    end

    context "when OS_CACERT is set" do
      before do
        allow(ENV).to receive(:[]).with("OS_CACERT").and_return("/env/ca.crt")
      end

      it "maps to ssl_ca_file" do
        result = driver.send(:load_env_vars)
        expect(result[:ssl_ca_file]).to eq("/env/ca.crt")
      end
    end

    context "when an OS_* var is empty string" do
      before do
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("")
      end

      it "ignores the empty value" do
        result = driver.send(:load_env_vars)
        expect(result).not_to have_key(:openstack_auth_url)
      end
    end

    context "with application credential env vars" do
      before do
        allow(ENV).to receive(:[]).with("OS_APPLICATION_CREDENTIAL_ID").and_return("appcred-id")
        allow(ENV).to receive(:[]).with("OS_APPLICATION_CREDENTIAL_SECRET").and_return("appcred-secret")
      end

      it "maps application credential env vars" do
        result = driver.send(:load_env_vars)
        expect(result[:openstack_application_credential_id]).to eq("appcred-id")
        expect(result[:openstack_application_credential_secret]).to eq("appcred-secret")
      end
    end
  end

  describe "#apply_clouds_config" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLIENT_SECURE_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLOUD").and_return(nil)
      Kitchen::Driver::Openstack::Clouds::ENV_VAR_MAP.each_key do |var|
        allow(ENV).to receive(:[]).with(var).and_return(nil)
      end
    end

    context "when clouds.yaml provides settings" do
      let(:config) { { openstack_cloud: "mycloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "merges clouds.yaml values into config" do
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(driver[:openstack_username]).to eq("testuser")
        expect(driver[:openstack_api_key]).to eq("testpass")
        expect(driver[:openstack_domain_id]).to eq("default")
        expect(driver[:openstack_region]).to eq("RegionOne")
      end

      it "does not override existing config values" do
        config[:openstack_region] = "OverriddenRegion"
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_region]).to eq("OverriddenRegion")
        expect(driver[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
      end
    end

    context "when SSL verify is false in clouds.yaml" do
      let(:config) { { openstack_cloud: "sslcloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "sets disable_ssl_validation in config" do
        driver.send(:apply_clouds_config)
        expect(driver[:disable_ssl_validation]).to eq(true)
      end
    end

    context "when no cloud is configured" do
      it "does not modify config" do
        original = driver[:openstack_username]
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_username]).to eq(original)
      end
    end

    context "using OS_CLOUD env var" do
      before do
        allow(ENV).to receive(:[]).with("OS_CLOUD").and_return("mycloud")
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
      end

      it "merges values from clouds.yaml via env var" do
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(driver[:openstack_username]).to eq("testuser")
      end
    end

    context "when only OS_* env vars are set (no clouds.yaml)" do
      before do
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("https://env.example.com:5000/v3")
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
        allow(ENV).to receive(:[]).with("OS_PASSWORD").and_return("envpass")
        allow(ENV).to receive(:[]).with("OS_DOMAIN_ID").and_return("envdomid")
        allow(ENV).to receive(:[]).with("OS_REGION_NAME").and_return("EnvRegion")
      end

      it "populates config from env vars" do
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_auth_url]).to eq("https://env.example.com:5000/v3")
        expect(driver[:openstack_username]).to eq("envuser")
        expect(driver[:openstack_api_key]).to eq("envpass")
        expect(driver[:openstack_domain_id]).to eq("envdomid")
        expect(driver[:openstack_region]).to eq("EnvRegion")
      end
    end

    context "when OS_* env vars override clouds.yaml values" do
      let(:config) { { openstack_cloud: "mycloud" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
        allow(ENV).to receive(:[]).with("OS_REGION_NAME").and_return("EnvRegionOverride")
      end

      it "uses env var value over clouds.yaml" do
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_region]).to eq("EnvRegionOverride")
        # clouds.yaml values still fill remaining keys
        expect(driver[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(driver[:openstack_username]).to eq("testuser")
      end
    end

    context "when kitchen.yml overrides OS_* env vars" do
      let(:config) { { openstack_region: "KitchenRegion" } }

      before do
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("https://env.example.com:5000/v3")
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
        allow(ENV).to receive(:[]).with("OS_PASSWORD").and_return("envpass")
        allow(ENV).to receive(:[]).with("OS_DOMAIN_ID").and_return("envdomid")
        allow(ENV).to receive(:[]).with("OS_REGION_NAME").and_return("EnvRegion")
      end

      it "uses kitchen.yml value over env var" do
        driver.send(:apply_clouds_config)
        expect(driver[:openstack_region]).to eq("KitchenRegion")
        # env var values still fill remaining keys
        expect(driver[:openstack_auth_url]).to eq("https://env.example.com:5000/v3")
        expect(driver[:openstack_username]).to eq("envuser")
      end
    end

    context "full precedence: kitchen.yml > OS_* > clouds.yaml" do
      let(:config) { { openstack_cloud: "mycloud", openstack_username: "kitchenuser" } }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?)
          .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
        allow(File).to receive(:read)
          .with(File.join(Dir.pwd, "clouds.yaml"))
          .and_return(YAML.dump(clouds_yaml_content))
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
        allow(ENV).to receive(:[]).with("OS_REGION_NAME").and_return("EnvRegion")
      end

      it "respects the full precedence chain" do
        driver.send(:apply_clouds_config)
        # kitchen.yml wins over both env and clouds.yaml
        expect(driver[:openstack_username]).to eq("kitchenuser")
        # OS_* env var wins over clouds.yaml
        expect(driver[:openstack_region]).to eq("EnvRegion")
        # clouds.yaml fills remaining nils
        expect(driver[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(driver[:openstack_api_key]).to eq("testpass")
      end
    end
  end

  describe "#openstack_server with clouds.yaml" do
    let(:config) { { openstack_cloud: "mycloud" } }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OS_CLIENT_CONFIG_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLIENT_SECURE_FILE").and_return(nil)
      allow(ENV).to receive(:[]).with("OS_CLOUD").and_return(nil)
      Kitchen::Driver::Openstack::Clouds::ENV_VAR_MAP.each_key do |var|
        allow(ENV).to receive(:[]).with(var).and_return(nil)
      end
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?)
        .with(File.join(Dir.pwd, "clouds.yaml")).and_return(true)
      allow(File).to receive(:read)
        .with(File.join(Dir.pwd, "clouds.yaml"))
        .and_return(YAML.dump(clouds_yaml_content))
    end

    it "populates server settings after apply_clouds_config" do
      driver.send(:apply_clouds_config)
      result = driver.send(:openstack_server)
      expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
      expect(result[:openstack_username]).to eq("testuser")
      expect(result[:openstack_api_key]).to eq("testpass")
      expect(result[:openstack_domain_id]).to eq("default")
      expect(result[:openstack_region]).to eq("RegionOne")
    end

    context "when kitchen.yml overrides clouds.yaml values" do
      let(:config) do
        {
          openstack_cloud: "mycloud",
          openstack_region: "OverriddenRegion",
        }
      end

      it "uses the kitchen.yml value for the overridden key" do
        driver.send(:apply_clouds_config)
        result = driver.send(:openstack_server)
        expect(result[:openstack_region]).to eq("OverriddenRegion")
        expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
      end
    end

    context "using OS_CLOUD env var" do
      let(:config) { {} }

      before do
        allow(ENV).to receive(:[]).with("OS_CLOUD").and_return("mycloud")
      end

      it "populates server settings from clouds.yaml via env var" do
        driver.send(:apply_clouds_config)
        result = driver.send(:openstack_server)
        expect(result[:openstack_auth_url]).to eq("https://keystone.example.com:5000/v3")
        expect(result[:openstack_username]).to eq("testuser")
      end
    end

    context "using only OS_* env vars (no clouds.yaml)" do
      let(:config) { {} }

      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(ENV).to receive(:[]).with("OS_AUTH_URL").and_return("https://env.example.com:5000/v3")
        allow(ENV).to receive(:[]).with("OS_USERNAME").and_return("envuser")
        allow(ENV).to receive(:[]).with("OS_PASSWORD").and_return("envpass")
        allow(ENV).to receive(:[]).with("OS_DOMAIN_ID").and_return("envdomid")
      end

      it "populates server settings from env vars" do
        driver.send(:apply_clouds_config)
        result = driver.send(:openstack_server)
        expect(result[:openstack_auth_url]).to eq("https://env.example.com:5000/v3")
        expect(result[:openstack_username]).to eq("envuser")
        expect(result[:openstack_api_key]).to eq("envpass")
        expect(result[:openstack_domain_id]).to eq("envdomid")
      end
    end
  end
end
