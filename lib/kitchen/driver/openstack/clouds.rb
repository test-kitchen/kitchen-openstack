# frozen_string_literal: true

#
# Author:: Lance Albertson (<lance@osuosl.org>)
#
# Copyright:: (C) 2026, Oregon State University
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

require "yaml"

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Support for OpenStack clouds.yaml client configuration
      module Clouds
        # Mapping of clouds.yaml auth keys to Fog OpenStack config keys
        CLOUDS_YAML_AUTH_MAP = {
          "auth_url" => :openstack_auth_url,
          "username" => :openstack_username,
          "password" => :openstack_api_key,
          "project_name" => :openstack_project_name,
          "project_id" => :openstack_project_id,
          "user_domain_name" => :openstack_user_domain,
          "user_domain_id" => :openstack_user_domain_id,
          "project_domain_name" => :openstack_project_domain,
          "project_domain_id" => :openstack_project_domain_id,
          "domain_id" => :openstack_domain_id,
          "domain_name" => :openstack_domain_name,
          "application_credential_id" => :openstack_application_credential_id,
          "application_credential_secret" => :openstack_application_credential_secret,
        }.freeze

        # Mapping of clouds.yaml top-level keys to Fog OpenStack config keys
        CLOUDS_YAML_TOP_MAP = {
          "region_name" => :openstack_region,
          "interface" => :openstack_endpoint_type,
          "identity_api_version" => :openstack_identity_api_version,
        }.freeze

        # Fog expects these config values to be strings. YAML may parse
        # unquoted scalars as integers/booleans, so normalize on ingest.
        STRING_CONFIG_KEYS = (CLOUDS_YAML_AUTH_MAP.values + CLOUDS_YAML_TOP_MAP.values).freeze

        # Mapping of OS_* environment variables to Fog OpenStack config keys
        ENV_VAR_MAP = {
          "OS_AUTH_URL" => :openstack_auth_url,
          "OS_USERNAME" => :openstack_username,
          "OS_PASSWORD" => :openstack_api_key,
          "OS_PROJECT_NAME" => :openstack_project_name,
          "OS_PROJECT_ID" => :openstack_project_id,
          "OS_USER_DOMAIN_NAME" => :openstack_user_domain,
          "OS_USER_DOMAIN_ID" => :openstack_user_domain_id,
          "OS_PROJECT_DOMAIN_NAME" => :openstack_project_domain,
          "OS_PROJECT_DOMAIN_ID" => :openstack_project_domain_id,
          "OS_DOMAIN_ID" => :openstack_domain_id,
          "OS_DOMAIN_NAME" => :openstack_domain_name,
          "OS_REGION_NAME" => :openstack_region,
          "OS_INTERFACE" => :openstack_endpoint_type,
          "OS_IDENTITY_API_VERSION" => :openstack_identity_api_version,
          "OS_APPLICATION_CREDENTIAL_ID" => :openstack_application_credential_id,
          "OS_APPLICATION_CREDENTIAL_SECRET" => :openstack_application_credential_secret,
          "OS_CACERT" => :ssl_ca_file,
        }.freeze

        private

        # Merges external config sources into the driver config hash.
        #
        # Precedence, highest first: kitchen.yml, `OS_*` environment
        # variables, then clouds.yaml. Only keys that are currently nil are
        # written, so anything set explicitly in kitchen.yml always wins.
        #
        # @return [void]
        def apply_clouds_config
          cc = load_clouds_config
          env = load_env_vars

          # env vars override clouds.yaml per upstream openstacksdk precedence
          merged = cc.merge(env)
          return if merged.empty?

          merged.each do |key, value|
            config[key] = value if config[key].nil?
          end

          # `verify: false` in clouds.yaml is how operators opt out of TLS
          # verification. openstacksdk documents no environment variable for it
          # (though its env loader does sweep up any OS_* name into an implicit
          # cloud), and ENV_VAR_MAP deliberately mirrors the documented set --
          # so for this driver clouds.yaml is the only source.
          return unless cc[:ssl_verify_peer] == false && !config[:disable_ssl_validation]

          config[:disable_ssl_validation] = true
        end

        # Reads `OS_*` environment variables and maps them to Fog config keys.
        #
        # Empty variables are ignored, so `OS_REGION_NAME=""` does not shadow
        # a region set in clouds.yaml.
        #
        # @return [Hash{Symbol => Object}] Fog config keys for the variables
        #   that are set
        def load_env_vars
          result = {}
          ENV_VAR_MAP.each do |env_var, fog_key|
            value = ENV[env_var]
            result[fog_key] = normalize_config_value(fog_key, value) if value && !value.empty?
          end
          result
        end

        # Resolves which named cloud to read out of clouds.yaml.
        #
        # @return [String, nil] the cloud name, or nil if none is configured
        def cloud_name
          config[:openstack_cloud] || ENV["OS_CLOUD"]
        end

        # Loads and merges clouds.yaml with secure.yaml, then translates the
        # named cloud entry into Fog-compatible config keys.
        #
        # secure.yaml wins over clouds.yaml, matching openstacksdk.
        #
        # @return [Hash{Symbol => Object}] Fog config keys, or an empty hash
        #   when no cloud is configured or the named cloud is absent
        def load_clouds_config
          name = cloud_name
          return {} unless name

          clouds_data, clouds_path = load_yaml_file("clouds.yaml", "OS_CLIENT_CONFIG_FILE")
          secure_data, secure_path = load_yaml_file("secure.yaml", "OS_CLIENT_SECURE_FILE")

          cloud = extract_cloud(clouds_data, name, clouds_path)
          secure = extract_cloud(secure_data, name, secure_path)

          cloud = deep_merge(cloud, secure)
          translate_cloud_config(cloud)
        end

        # Loads the first of the standard OpenStack config locations that
        # exists.
        #
        # @param filename [String] `"clouds.yaml"` or `"secure.yaml"`
        # @param env_var [String] the environment variable that overrides the
        #   search path for this file
        # @return [Array(Hash, String), Array(Hash, nil)] the parsed document
        #   and the path it came from; an empty hash and nil if no file was
        #   found
        # @raise [Kitchen::ActionFailed] if the file exists but is not valid
        #   YAML, or does not parse to a mapping
        def load_yaml_file(filename, env_var)
          paths = clouds_yaml_search_paths(filename, env_var)
          path = paths.find { |p| File.exist?(p) }
          return [{}, nil] unless path

          debug "Loading #{filename} from #{path}"
          data = parse_yaml(path)

          # A clouds.yaml that parses to a list or a scalar is a mistake worth
          # naming, rather than a NoMethodError three frames later.
          raise ActionFailed, "#{path} must contain a YAML mapping" unless data.is_a?(Hash)

          [data, path]
        end

        # Parses one YAML document, turning a syntax error into a message that
        # names the offending file.
        #
        # @param path [String] the file to parse
        # @return [Object] the parsed document
        # @raise [Kitchen::ActionFailed] if the file is not valid YAML
        def parse_yaml(path)
          YAML.safe_load_file(path, permitted_classes: [Date]) || {}
        rescue Psych::Exception => e
          raise ActionFailed, "Could not parse #{path}: #{e.message}"
        end

        # Standard OpenStack client config search locations, highest priority
        # first.
        #
        # @param filename [String] the file being looked for
        # @param env_var [String] the environment variable that overrides it
        # @return [Array<String>] candidate paths
        def clouds_yaml_search_paths(filename, env_var)
          paths = []
          paths << ENV[env_var] if ENV[env_var]
          paths << config[:clouds_yaml_path] if config[:clouds_yaml_path] && filename == "clouds.yaml"
          paths << File.join(Dir.pwd, filename)
          home = user_home
          paths << File.join(home, ".config", "openstack", filename) if home
          paths << File.join("/etc/openstack", filename)
          paths
        end

        # The user's home directory, or nil if there isn't one.
        #
        # `Dir.home` raises when HOME is unset and the uid has no passwd entry,
        # which is the ordinary state inside a container running as an arbitrary
        # uid. That must not take out the whole search -- /etc/openstack is
        # still worth trying.
        #
        # @return [String, nil] the home directory, or nil if it cannot be
        #   determined
        def user_home
          Dir.home
        rescue ArgumentError
          nil
        end

        # Pulls one named cloud entry out of a parsed clouds/secure document.
        #
        # An absent entry is an empty hash: clouds.yaml and secure.yaml are
        # merged, and it is normal for a cloud to appear in only one of them.
        # An entry that is *present but not a mapping* is always a mistake, and
        # is reported rather than silently discarded -- otherwise the driver
        # carries on with nil credentials and the user sees an opaque Keystone
        # auth failure that never mentions their config file.
        #
        # @param data [Hash] the parsed document
        # @param name [String] the cloud name to extract
        # @param source [String] the file the document came from, for errors
        # @return [Hash] the cloud entry, or an empty hash if it is absent
        # @raise [Kitchen::ActionFailed] if `clouds` or the named entry is
        #   present but is not a mapping
        def extract_cloud(data, name, source)
          clouds = data["clouds"]
          return {} if clouds.nil?
          raise ActionFailed, "The clouds section of #{source} must be a YAML mapping" unless clouds.is_a?(Hash)

          cloud = clouds[name]
          return {} if cloud.nil?
          raise ActionFailed, "Cloud <#{name}> in #{source} must be a YAML mapping" unless cloud.is_a?(Hash)

          cloud
        end

        # Recursively merges `override` onto `base` without mutating either.
        #
        # @param base [Hash] the lower-priority hash
        # @param override [Hash] the higher-priority hash
        # @return [Hash] a new merged hash
        def deep_merge(base, override)
          result = base.dup
          override.each do |key, value|
            result[key] = if result[key].is_a?(Hash) && value.is_a?(Hash)
                            deep_merge(result[key], value)
                          else
                            value
                          end
          end
          result
        end

        # Converts a clouds.yaml cloud entry into Fog-compatible config keys.
        #
        # @param cloud [Hash] a single cloud entry
        # @return [Hash{Symbol => Object}] Fog config keys
        def translate_cloud_config(cloud)
          result = {}

          # Map auth section
          auth = cloud["auth"] || {}
          CLOUDS_YAML_AUTH_MAP.each do |yaml_key, fog_key|
            value = auth[yaml_key]
            result[fog_key] = normalize_config_value(fog_key, value) if value
          end

          # Map top-level keys
          CLOUDS_YAML_TOP_MAP.each do |yaml_key, fog_key|
            value = cloud[yaml_key]
            result[fog_key] = normalize_config_value(fog_key, value) if value
          end

          # SSL settings
          result[:ssl_verify_peer] = cloud["verify"] if cloud.key?("verify")
          result[:ssl_ca_file] = cloud["cacert"] if cloud["cacert"]

          result
        end

        # Coerces values Fog insists on receiving as strings.
        #
        # YAML parses `identity_api_version: 3` and `project_id: 12345` as
        # Integers, which Fog then fails on.
        #
        # @param fog_key [Symbol] the Fog config key
        # @param value [Object] the raw value from YAML or the environment
        # @return [Object] the value, stringified when the key requires it
        def normalize_config_value(fog_key, value)
          return value unless STRING_CONFIG_KEYS.include?(fog_key)

          value.to_s
        end
      end
    end
  end
end
