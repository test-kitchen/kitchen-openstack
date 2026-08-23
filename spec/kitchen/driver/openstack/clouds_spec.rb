# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "yaml"

RSpec.describe Kitchen::Driver::Openstack::Clouds do
  include_context "with a configured driver"

  # A directory that is never created, used to pin the search path away from
  # the developer's real files.
  def nowhere
    File.join(Dir.tmpdir, "kitchen-openstack-does-not-exist")
  end

  # Pin every location clouds_yaml_search_paths consults.
  #
  # Scrubbing OS_* is not sufficient on its own: the search falls through to
  # ./{clouds,secure}.yaml, ~/.config/openstack/ and /etc/openstack/ whenever
  # the pinned path does not exist, so on an operator's machine a real
  # secure.yaml naming a cloud these fixtures also use would fail examples
  # here -- and RSpec's diff would print their real password into the terminal
  # and the CI log.
  before do
    allow(Dir).to receive_messages(pwd: nowhere, home: nowhere)
    allow(File).to receive(:exist?).with(a_string_starting_with("/etc/openstack/")).and_return(false)
  end

  # Real files on disk rather than a stubbed File.exist?: these examples are
  # the only place the driver touches the filesystem, and stubbing it out was
  # hiding whether the search-path logic worked at all.
  #
  # Created lazily and torn down after: most examples in this file never touch
  # the filesystem, and building then recursively removing a tmpdir for each of
  # them was the largest source of dead I/O in the suite.
  def tmpdir
    @tmpdir ||= Dir.mktmpdir("kitchen-openstack-clouds")
  end

  after { FileUtils.remove_entry(@tmpdir) if @tmpdir }

  # Writes a YAML document into the sandbox and returns its path.
  def write_yaml(filename, content)
    path = File.join(tmpdir, filename)
    File.write(path, content.is_a?(String) ? content : YAML.dump(content))
    path
  end

  let(:clouds_yaml) do
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
          "identity_api_version" => 3,
        },
        "minimal" => {
          "auth" => {
            "auth_url" => "https://minimal.example.com:5000/v3",
            "username" => "minuser",
          },
        },
      },
    }
  end

  # Point the loader at the sandbox and return the clouds.yaml path.
  #
  # OS_CLIENT_SECURE_FILE is always pinned, at a file that only exists when the
  # example asked for one, so no example can silently pick up a real
  # secure.yaml.
  def use_clouds_file(content = clouds_yaml, secure: nil, env: {})
    path = write_yaml("clouds.yaml", content)
    vars = {
      "OS_CLIENT_CONFIG_FILE" => path,
      "OS_CLIENT_SECURE_FILE" => secure ? write_yaml("secure.yaml", secure) : File.join(tmpdir, "no-secure.yaml"),
    }
    stub_env(vars.merge(env))
    path
  end

  describe "#cloud_name" do
    it "reads openstack_cloud from kitchen.yml" do
      config[:openstack_cloud] = "mycloud"

      expect(driver.send(:cloud_name)).to eq("mycloud")
    end

    it "falls back to OS_CLOUD" do
      stub_env("OS_CLOUD" => "envcloud")

      expect(driver.send(:cloud_name)).to eq("envcloud")
    end

    it "prefers kitchen.yml over OS_CLOUD" do
      stub_env("OS_CLOUD" => "envcloud")
      config[:openstack_cloud] = "mycloud"

      expect(driver.send(:cloud_name)).to eq("mycloud")
    end

    it "is nil when neither is set" do
      expect(driver.send(:cloud_name)).to be_nil
    end
  end

  describe "#clouds_yaml_search_paths" do
    before { stub_env }

    it "searches cwd, then the user config dir, then /etc/openstack" do
      allow(Dir).to receive_messages(pwd: "/work", home: "/home/me")

      expect(driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")).to eq(
        [
          "/work/clouds.yaml",
          "/home/me/.config/openstack/clouds.yaml",
          "/etc/openstack/clouds.yaml",
        ]
      )
    end

    # Dir.home raises ArgumentError when HOME is unset and the uid has no
    # passwd entry -- the ordinary state in a container running as an arbitrary
    # uid. With OS_CLOUD set that used to crash the driver before /etc/openstack
    # was ever tried, which is the one location such a container is likely to
    # have.
    it "skips the user config dir when there is no home directory" do
      allow(Dir).to receive(:pwd).and_return("/work")
      allow(Dir).to receive(:home).and_raise(ArgumentError, "couldn't find HOME environment -- expanding `~'")

      expect(driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")).to eq(
        [
          "/work/clouds.yaml",
          "/etc/openstack/clouds.yaml",
        ]
      )
    end

    it "puts the env var override first" do
      stub_env("OS_CLIENT_CONFIG_FILE" => "/custom/clouds.yaml")

      expect(driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE").first)
        .to eq("/custom/clouds.yaml")
    end

    it "honours clouds_yaml_path from kitchen.yml" do
      config[:clouds_yaml_path] = "/kitchen/clouds.yaml"

      expect(driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE"))
        .to include("/kitchen/clouds.yaml")
    end

    it "ranks the env var above clouds_yaml_path" do
      stub_env("OS_CLIENT_CONFIG_FILE" => "/custom/clouds.yaml")
      config[:clouds_yaml_path] = "/kitchen/clouds.yaml"

      paths = driver.send(:clouds_yaml_search_paths, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")

      expect(paths.index("/custom/clouds.yaml")).to be < paths.index("/kitchen/clouds.yaml")
    end

    it "does not apply clouds_yaml_path to secure.yaml" do
      config[:clouds_yaml_path] = "/kitchen/clouds.yaml"

      expect(driver.send(:clouds_yaml_search_paths, "secure.yaml", "OS_CLIENT_SECURE_FILE"))
        .not_to include("/kitchen/clouds.yaml")
    end
  end

  describe "#load_yaml_file" do
    it "returns an empty hash when no file is found" do
      stub_env
      allow(Dir).to receive_messages(pwd: File.join(tmpdir, "empty"), home: File.join(tmpdir, "empty"))

      expect(driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")).to eq([{}, nil])
    end

    it "parses the first file that exists, and reports where it came from" do
      path = use_clouds_file

      expect(driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE"))
        .to eq([clouds_yaml, path])
    end

    it "treats an empty file as an empty document" do
      path = write_yaml("clouds.yaml", "")
      stub_env("OS_CLIENT_CONFIG_FILE" => path)

      expect(driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")).to eq([{}, path])
    end

    it "allows Date values, which appear in expiry fields" do
      path = write_yaml("clouds.yaml", "clouds:\n  mycloud:\n    expires: 2030-01-01\n")
      stub_env("OS_CLIENT_CONFIG_FILE" => path)

      expect(driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE").first)
        .to eq("clouds" => { "mycloud" => { "expires" => Date.new(2030, 1, 1) } })
    end

    it "names the file when the YAML is malformed" do
      path = write_yaml("clouds.yaml", "clouds:\n  mycloud:\n   - broken: [\n")
      stub_env("OS_CLIENT_CONFIG_FILE" => path)

      expect { driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE") }
        .to raise_error(Kitchen::ActionFailed, /Could not parse #{Regexp.escape(path)}/)
    end

    it "rejects a document that is not a mapping" do
      path = write_yaml("clouds.yaml", "- one\n- two\n")
      stub_env("OS_CLIENT_CONFIG_FILE" => path)

      expect { driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE") }
        .to raise_error(Kitchen::ActionFailed, /must contain a YAML mapping/)
    end

    it "logs where it loaded the file from" do
      path = write_yaml("clouds.yaml", clouds_yaml)
      stub_env("OS_CLIENT_CONFIG_FILE" => path)

      driver.send(:load_yaml_file, "clouds.yaml", "OS_CLIENT_CONFIG_FILE")

      expect(logged_output.string).to include("Loading clouds.yaml from #{path}")
    end
  end

  describe "#extract_cloud" do
    it "pulls out the named cloud" do
      expect(driver.send(:extract_cloud, clouds_yaml, "minimal", "clouds.yaml"))
        .to eq("auth" => { "auth_url" => "https://minimal.example.com:5000/v3", "username" => "minuser" })
    end

    # An absent entry is normal: clouds.yaml and secure.yaml are merged, and a
    # cloud is allowed to appear in only one of them.
    it "returns an empty hash for an unknown cloud" do
      expect(driver.send(:extract_cloud, clouds_yaml, "nope", "clouds.yaml")).to eq({})
    end

    it "returns an empty hash when there is no clouds key" do
      expect(driver.send(:extract_cloud, { "other" => {} }, "mycloud", "clouds.yaml")).to eq({})
    end

    # A present-but-malformed entry is always a mistake. Returning {} here let
    # the driver carry on with nil credentials, and the user saw an opaque
    # Keystone auth failure that never mentioned their config file.
    it "names the file when clouds is present but not a mapping" do
      expect { driver.send(:extract_cloud, { "clouds" => "oops" }, "mycloud", "/etc/openstack/clouds.yaml") }
        .to raise_error(Kitchen::ActionFailed, %r{clouds section of /etc/openstack/clouds.yaml must be a YAML mapping})
    end

    it "names the cloud when the entry is present but not a mapping" do
      entry = { "clouds" => { "mycloud" => "https://example.com:5000/v3" } }

      expect { driver.send(:extract_cloud, entry, "mycloud", "/etc/openstack/clouds.yaml") }
        .to raise_error(Kitchen::ActionFailed, %r{Cloud <mycloud> in /etc/openstack/clouds.yaml must be a YAML mapping})
    end
  end

  describe "#deep_merge" do
    it "merges nested hashes" do
      base = { "auth" => { "username" => "a", "password" => "b" }, "region_name" => "r" }
      override = { "auth" => { "password" => "c" } }

      expect(driver.send(:deep_merge, base, override))
        .to eq("auth" => { "username" => "a", "password" => "c" }, "region_name" => "r")
    end

    it "replaces scalars rather than merging them" do
      expect(driver.send(:deep_merge, { "a" => 1 }, { "a" => 2 })).to eq("a" => 2)
    end

    it "replaces a hash with a scalar when the override says so" do
      expect(driver.send(:deep_merge, { "a" => { "b" => 1 } }, { "a" => 2 })).to eq("a" => 2)
    end

    it "adds keys only present in the override" do
      expect(driver.send(:deep_merge, { "a" => 1 }, { "b" => 2 })).to eq("a" => 1, "b" => 2)
    end

    it "does not mutate either input" do
      base = { "auth" => { "username" => "a" } }
      override = { "auth" => { "password" => "b" } }

      driver.send(:deep_merge, base, override)

      expect(base).to eq("auth" => { "username" => "a" })
      expect(override).to eq("auth" => { "password" => "b" })
    end
  end

  describe "#translate_cloud_config" do
    it "maps every auth key it knows about" do
      cloud = {
        "auth" => {
          "auth_url" => "https://keystone.example.com:5000/v3",
          "username" => "testuser",
          "password" => "testpass",
          "project_name" => "testproject",
          "project_id" => "pid",
          "user_domain_name" => "Default",
          "user_domain_id" => "udid",
          "project_domain_name" => "Default",
          "project_domain_id" => "pdid",
          "domain_id" => "default",
          "domain_name" => "Default",
        },
      }

      expect(driver.send(:translate_cloud_config, cloud)).to eq(
        openstack_auth_url: "https://keystone.example.com:5000/v3",
        openstack_username: "testuser",
        openstack_api_key: "testpass",
        openstack_project_name: "testproject",
        openstack_project_id: "pid",
        openstack_user_domain: "Default",
        openstack_user_domain_id: "udid",
        openstack_project_domain: "Default",
        openstack_project_domain_id: "pdid",
        openstack_domain_id: "default",
        openstack_domain_name: "Default"
      )
    end

    it "maps the top-level keys" do
      cloud = { "region_name" => "RegionOne", "interface" => "public", "identity_api_version" => "3" }

      expect(driver.send(:translate_cloud_config, cloud)).to eq(
        openstack_region: "RegionOne",
        openstack_endpoint_type: "public",
        openstack_identity_api_version: "3"
      )
    end

    it "maps application credentials" do
      cloud = { "auth" => { "application_credential_id" => "acid", "application_credential_secret" => "acsecret" } }

      expect(driver.send(:translate_cloud_config, cloud)).to eq(
        openstack_application_credential_id: "acid",
        openstack_application_credential_secret: "acsecret"
      )
    end

    it "returns an empty hash for an empty cloud" do
      expect(driver.send(:translate_cloud_config, {})).to eq({})
    end

    it "skips keys it does not recognize" do
      expect(driver.send(:translate_cloud_config, { "auth" => { "nonsense" => "x" } })).to eq({})
    end

    # YAML parses `identity_api_version: 3` and numeric project ids as
    # Integers; Fog then chokes on them.
    it "stringifies values YAML parsed as numbers" do
      cloud = { "identity_api_version" => 3, "auth" => { "project_id" => 12345 } }

      expect(driver.send(:translate_cloud_config, cloud))
        .to eq(openstack_identity_api_version: "3", openstack_project_id: "12345")
    end

    describe "SSL settings" do
      it "carries a cacert path through" do
        expect(driver.send(:translate_cloud_config, { "cacert" => "/path/ca.crt" }))
          .to eq(ssl_ca_file: "/path/ca.crt")
      end

      it "carries verify: false through as a boolean" do
        expect(driver.send(:translate_cloud_config, { "verify" => false }))
          .to eq(ssl_verify_peer: false)
      end

      it "carries verify: true through" do
        expect(driver.send(:translate_cloud_config, { "verify" => true }))
          .to eq(ssl_verify_peer: true)
      end

      it "omits ssl_verify_peer when verify is absent" do
        expect(driver.send(:translate_cloud_config, {})).not_to have_key(:ssl_verify_peer)
      end
    end
  end

  describe "#load_env_vars" do
    it "is empty when nothing is set" do
      stub_env

      expect(driver.send(:load_env_vars)).to eq({})
    end

    it "maps every variable it knows about" do
      stub_env(
        "OS_AUTH_URL" => "https://env.example.com:5000/v3",
        "OS_USERNAME" => "envuser",
        "OS_PASSWORD" => "envpass",
        "OS_PROJECT_NAME" => "envproject",
        "OS_PROJECT_ID" => "envpid",
        "OS_USER_DOMAIN_NAME" => "EnvDomain",
        "OS_USER_DOMAIN_ID" => "envudid",
        "OS_PROJECT_DOMAIN_NAME" => "EnvProjDomain",
        "OS_PROJECT_DOMAIN_ID" => "envpdid",
        "OS_DOMAIN_ID" => "envdomid",
        "OS_DOMAIN_NAME" => "EnvDomainName",
        "OS_REGION_NAME" => "EnvRegion",
        "OS_INTERFACE" => "internal",
        "OS_IDENTITY_API_VERSION" => "3",
        "OS_APPLICATION_CREDENTIAL_ID" => "envacid",
        "OS_APPLICATION_CREDENTIAL_SECRET" => "envacsecret",
        "OS_CACERT" => "/env/ca.crt"
      )

      expect(driver.send(:load_env_vars)).to eq(
        openstack_auth_url: "https://env.example.com:5000/v3",
        openstack_username: "envuser",
        openstack_api_key: "envpass",
        openstack_project_name: "envproject",
        openstack_project_id: "envpid",
        openstack_user_domain: "EnvDomain",
        openstack_user_domain_id: "envudid",
        openstack_project_domain: "EnvProjDomain",
        openstack_project_domain_id: "envpdid",
        openstack_domain_id: "envdomid",
        openstack_domain_name: "EnvDomainName",
        openstack_region: "EnvRegion",
        openstack_endpoint_type: "internal",
        openstack_identity_api_version: "3",
        openstack_application_credential_id: "envacid",
        openstack_application_credential_secret: "envacsecret",
        ssl_ca_file: "/env/ca.crt"
      )
    end

    it "covers the whole documented map" do
      expect(described_class::ENV_VAR_MAP.keys).to all(start_with("OS_"))
    end

    # An exported-but-empty variable is how shells leave a cleared setting; it
    # must not shadow the same key from clouds.yaml.
    it "ignores empty variables" do
      stub_env("OS_AUTH_URL" => "", "OS_USERNAME" => "envuser")

      expect(driver.send(:load_env_vars)).to eq(openstack_username: "envuser")
    end
  end

  describe "#load_clouds_config" do
    it "is empty when no cloud is named" do
      use_clouds_file

      expect(driver.send(:load_clouds_config)).to eq({})
    end

    it "translates the named cloud" do
      use_clouds_file(env: { "OS_CLOUD" => "mycloud" })

      expect(driver.send(:load_clouds_config)).to include(
        openstack_auth_url: "https://keystone.example.com:5000/v3",
        openstack_username: "testuser",
        openstack_api_key: "testpass",
        openstack_region: "RegionOne",
        openstack_identity_api_version: "3"
      )
    end

    it "is empty when the named cloud is absent" do
      use_clouds_file(env: { "OS_CLOUD" => "nonexistent" })

      expect(driver.send(:load_clouds_config)).to eq({})
    end

    it "is empty when there is no clouds.yaml at all" do
      stub_env("OS_CLOUD" => "mycloud")
      allow(Dir).to receive_messages(pwd: File.join(tmpdir, "empty"), home: File.join(tmpdir, "empty"))

      expect(driver.send(:load_clouds_config)).to eq({})
    end

    it "reads clouds.yaml from clouds_yaml_path" do
      stub_env
      config[:openstack_cloud] = "mycloud"
      config[:clouds_yaml_path] = write_yaml("clouds.yaml", clouds_yaml)

      expect(driver.send(:load_clouds_config)).to include(openstack_username: "testuser")
    end

    describe "secure.yaml" do
      let(:secure_yaml) do
        { "clouds" => { "mycloud" => { "auth" => { "password" => "secretpass" } } } }
      end

      it "overrides the password from clouds.yaml" do
        use_clouds_file(secure: secure_yaml, env: { "OS_CLOUD" => "mycloud" })

        expect(driver.send(:load_clouds_config)).to include(openstack_api_key: "secretpass")
      end

      it "leaves the rest of clouds.yaml intact" do
        use_clouds_file(secure: secure_yaml, env: { "OS_CLOUD" => "mycloud" })

        expect(driver.send(:load_clouds_config)).to include(openstack_username: "testuser")
      end

      it "ignores entries for other clouds" do
        other = { "clouds" => { "othercloud" => { "auth" => { "password" => "nope" } } } }
        use_clouds_file(secure: other, env: { "OS_CLOUD" => "mycloud" })

        expect(driver.send(:load_clouds_config)).to include(openstack_api_key: "testpass")
      end
    end
  end

  describe "#apply_clouds_config" do
    it "does nothing when there is nothing to apply" do
      stub_env
      allow(Dir).to receive_messages(pwd: File.join(tmpdir, "empty"), home: File.join(tmpdir, "empty"))

      driver.send(:apply_clouds_config)

      expect(driver[:openstack_username]).to be_nil
    end

    it "fills in values from clouds.yaml" do
      use_clouds_file(env: { "OS_CLOUD" => "mycloud" })

      driver.send(:apply_clouds_config)

      expect(driver[:openstack_username]).to eq("testuser")
      expect(driver[:openstack_api_key]).to eq("testpass")
      expect(driver[:openstack_region]).to eq("RegionOne")
    end

    it "fills in values from OS_* variables with no clouds.yaml" do
      stub_env("OS_AUTH_URL" => "https://env.example.com:5000/v3", "OS_USERNAME" => "envuser")
      allow(Dir).to receive_messages(pwd: File.join(tmpdir, "empty"), home: File.join(tmpdir, "empty"))

      driver.send(:apply_clouds_config)

      expect(driver[:openstack_username]).to eq("envuser")
    end

    describe "precedence" do
      it "lets OS_* variables beat clouds.yaml" do
        use_clouds_file(env: { "OS_CLOUD" => "mycloud", "OS_USERNAME" => "envuser" })

        driver.send(:apply_clouds_config)

        expect(driver[:openstack_username]).to eq("envuser")
      end

      it "lets kitchen.yml beat OS_* variables" do
        use_clouds_file(env: { "OS_CLOUD" => "mycloud", "OS_USERNAME" => "envuser" })
        config[:openstack_username] = "kitchenuser"

        driver.send(:apply_clouds_config)

        expect(driver[:openstack_username]).to eq("kitchenuser")
      end

      it "resolves the full three-way chain per key" do
        use_clouds_file(
          env: {
            "OS_CLOUD" => "mycloud",
            "OS_USERNAME" => "envuser",
            "OS_REGION_NAME" => "EnvRegion",
          }
        )
        config[:openstack_username] = "kitchenuser"

        driver.send(:apply_clouds_config)

        expect(driver[:openstack_username]).to eq("kitchenuser")  # kitchen.yml wins
        expect(driver[:openstack_region]).to eq("EnvRegion")      # env beats clouds.yaml
        expect(driver[:openstack_api_key]).to eq("testpass")      # only clouds.yaml has it
      end
    end

    describe "SSL handling" do
      it "turns off validation when clouds.yaml says verify: false" do
        cloud = clouds_yaml
        cloud["clouds"]["mycloud"]["verify"] = false
        use_clouds_file(cloud, env: { "OS_CLOUD" => "mycloud" })

        driver.send(:apply_clouds_config)

        expect(driver[:disable_ssl_validation]).to be(true)
      end

      it "leaves validation on when verify is true" do
        cloud = clouds_yaml
        cloud["clouds"]["mycloud"]["verify"] = true
        use_clouds_file(cloud, env: { "OS_CLOUD" => "mycloud" })

        driver.send(:apply_clouds_config)

        expect(driver[:disable_ssl_validation]).to be_nil
      end

      it "leaves validation on when verify is absent" do
        use_clouds_file(env: { "OS_CLOUD" => "mycloud" })

        driver.send(:apply_clouds_config)

        expect(driver[:disable_ssl_validation]).to be_nil
      end

      it "carries a cacert from clouds.yaml into ssl_ca_file" do
        cloud = clouds_yaml
        cloud["clouds"]["mycloud"]["cacert"] = "/path/ca.crt"
        use_clouds_file(cloud, env: { "OS_CLOUD" => "mycloud" })

        driver.send(:apply_clouds_config)

        expect(driver[:ssl_ca_file]).to eq("/path/ca.crt")
      end

      it "carries OS_CACERT into ssl_ca_file" do
        use_clouds_file(env: { "OS_CLOUD" => "mycloud", "OS_CACERT" => "/env/ca.crt" })

        driver.send(:apply_clouds_config)

        expect(driver[:ssl_ca_file]).to eq("/env/ca.crt")
      end
    end
  end

  describe "end-to-end through openstack_server" do
    it "hands clouds.yaml credentials to Fog" do
      use_clouds_file(env: { "OS_CLOUD" => "mycloud" })

      driver.send(:apply_clouds_config)

      expect(driver.send(:openstack_server)).to include(
        openstack_username: "testuser",
        openstack_api_key: "testpass",
        openstack_auth_url: "https://keystone.example.com:5000/v3",
        openstack_domain_id: "default",
        openstack_region: "RegionOne"
      )
    end

    it "prefixes the identity API version so Fog does not re-coerce it" do
      use_clouds_file(env: { "OS_CLOUD" => "mycloud" })

      driver.send(:apply_clouds_config)

      expect(driver.send(:openstack_server)[:openstack_identity_api_version]).to eq("v3")
    end

    it "routes a clouds.yaml cacert into the Excon connection options" do
      cloud = clouds_yaml
      cloud["clouds"]["mycloud"]["cacert"] = "/path/ca.crt"
      use_clouds_file(cloud, env: { "OS_CLOUD" => "mycloud" })

      driver.send(:apply_clouds_config)

      expect(driver.send(:openstack_server)[:connection_options])
        .to include(ssl_ca_file: "/path/ca.crt")
    end
  end

  describe "constants" do
    # Pinned as a literal rather than recomputed from the two maps: the
    # constant is *defined* as those maps' values, so asserting the same
    # expression could never fail. Spelled out, adding a clouds.yaml mapping
    # forces a deliberate decision about whether Fog wants it stringified.
    it "treats every mapped auth and top-level key as string-valued" do
      expect(described_class::STRING_CONFIG_KEYS).to match_array(
        %i{
          openstack_auth_url
          openstack_username
          openstack_api_key
          openstack_project_name
          openstack_project_id
          openstack_user_domain
          openstack_user_domain_id
          openstack_project_domain
          openstack_project_domain_id
          openstack_domain_id
          openstack_domain_name
          openstack_application_credential_id
          openstack_application_credential_secret
          openstack_region
          openstack_endpoint_type
          openstack_identity_api_version
        }
      )
    end

    it "does not stringify the SSL keys, which are a boolean and a path" do
      expect(described_class::STRING_CONFIG_KEYS).not_to include(:ssl_verify_peer, :ssl_ca_file)
    end
  end
end
