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
        # Precedence: kitchen.yml > OS_* env vars > clouds.yaml
        # Only sets keys that are currently nil so that kitchen.yml
        # values always take precedence.
        def apply_clouds_config
          cc = load_clouds_config
          env = load_env_vars

          # env vars override clouds.yaml per upstream openstacksdk precedence
          merged = cc.merge(env)
          return if merged.empty?

          merged.each do |key, value|
            config[key] = value if config[key].nil?
          end

          # Apply SSL settings: env vars or clouds.yaml disabling verification
          ssl_verify = env.key?(:ssl_verify_peer) ? env[:ssl_verify_peer] : cc[:ssl_verify_peer]
          return unless ssl_verify == false && !config[:disable_ssl_validation]

          config[:disable_ssl_validation] = true
        end

        # Reads OS_* environment variables and maps them to Fog config keys.
        # Returns a hash of fog config symbols for any set env vars.
        def load_env_vars
          result = {}
          ENV_VAR_MAP.each do |env_var, fog_key|
            value = ENV[env_var]
            result[fog_key] = value if value && !value.empty?
          end
          result
        end

        # Resolves the cloud name from config or the OS_CLOUD environment variable
        def cloud_name
          config[:openstack_cloud] || ENV["OS_CLOUD"]
        end

        # Loads and merges clouds.yaml with secure.yaml, then translates the
        # named cloud entry into Fog-compatible config keys.
        # Returns a hash of fog config symbols, or empty hash if no cloud configured.
        def load_clouds_config
          name = cloud_name
          return {} unless name

          clouds_data = load_yaml_file("clouds.yaml", "OS_CLIENT_CONFIG_FILE")
          secure_data = load_yaml_file("secure.yaml", "OS_CLIENT_SECURE_FILE")

          cloud = extract_cloud(clouds_data, name)
          secure = extract_cloud(secure_data, name)

          cloud = deep_merge(cloud, secure)
          translate_cloud_config(cloud)
        end

        # Search standard OpenStack config file locations for the given filename
        def load_yaml_file(filename, env_var)
          paths = clouds_yaml_search_paths(filename, env_var)
          path = paths.find { |p| File.exist?(p) }
          return {} unless path

          debug "Loading #{filename} from #{path}"
          YAML.safe_load(File.read(path), permitted_classes: [Date]) || {} # rubocop: disable Style/YAMLFileRead
        end

        def clouds_yaml_search_paths(filename, env_var)
          paths = []
          paths << ENV[env_var] if ENV[env_var]
          paths << config[:clouds_yaml_path] if config[:clouds_yaml_path] && filename == "clouds.yaml"
          paths << File.join(Dir.pwd, filename)
          paths << File.join(Dir.home, ".config", "openstack", filename)
          paths << File.join("/etc/openstack", filename)
          paths
        end

        def extract_cloud(data, name)
          clouds = data["clouds"] || {}
          cloud = clouds[name]
          return {} unless cloud

          cloud
        end

        # Deep merge two hashes (secure overrides clouds)
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

        # Convert a clouds.yaml cloud entry into Fog-compatible config keys
        def translate_cloud_config(cloud)
          result = {}

          # Map auth section
          auth = cloud["auth"] || {}
          CLOUDS_YAML_AUTH_MAP.each do |yaml_key, fog_key|
            result[fog_key] = auth[yaml_key] if auth[yaml_key]
          end

          # Map top-level keys
          CLOUDS_YAML_TOP_MAP.each do |yaml_key, fog_key|
            result[fog_key] = cloud[yaml_key] if cloud[yaml_key]
          end

          # SSL settings
          result[:ssl_verify_peer] = cloud["verify"] if cloud.key?("verify")
          result[:ssl_ca_file] = cloud["cacert"] if cloud["cacert"]

          result
        end
      end
    end
  end
end
