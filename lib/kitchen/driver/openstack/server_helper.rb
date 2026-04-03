# frozen_string_literal: true

#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
# Author:: JJ Asghar (<jj@chef.io>)
# Author:: Lance Albertson (<lance@osuosl.org>)
#
# Copyright:: (C) 2013-2015, Jonathan Hartman
# Copyright:: (C) 2015-2020, Chef Software Inc.
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

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Server creation and resource finders (image, flavor, network)
      module ServerHelper
        private

        def create_server
          server_def = init_configuration
          raise(ActionFailed, "Cannot specify both network_ref and network_id") if config[:network_id] && config[:network_ref]

          if config[:network_id]
            networks = [].push(config[:network_id])
            server_def[:nics] = networks.flatten.map do |net_id|
              { "net_id" => net_id }
            end
          elsif config[:network_ref]
            networks = [].push(config[:network_ref])
            server_def[:nics] = networks.flatten.map do |net|
              { "net_id" => find_network(net).id }
            end
          end

          if config[:block_device_mapping]
            server_def[:block_device_mapping] = get_bdm(config)
          end

          %i{
            security_groups
            key_name
            user_data
            config_drive
            metadata
          }.each do |c|
            server_def[c] = optional_config(c) if config[c]
          end

          if config[:cloud_config]
            raise(ActionFailed, "Cannot specify both cloud_config and user_data") if config[:user_data]

            server_def[:user_data] = YAML.dump(Kitchen::Util.stringified_hash(config[:cloud_config])).gsub(/^---\n/, "#cloud-config\n")
          end

          # Can't use the Fog bootstrap and/or setup methods here; they require a
          # public IP address that can't be guaranteed to exist across all
          # OpenStack deployments (e.g. TryStack ARM only has private IPs).
          compute.servers.create(server_def)
        end

        def init_configuration
          raise(ActionFailed, "Cannot specify both image_ref and image_id") if config[:image_id] && config[:image_ref]
          raise(ActionFailed, "Cannot specify both flavor_ref and flavor_id") if config[:flavor_id] && config[:flavor_ref]

          {
            name: config[:server_name],
            image_ref: config[:image_id] || find_image(config[:image_ref]).id,
            flavor_ref: config[:flavor_id] || find_flavor(config[:flavor_ref]).id,
            availability_zone: config[:availability_zone],
          }
        end

        def optional_config(c)
          case c
          when :security_groups
            config[c] if config[c].is_a?(Array)
          when :user_data
            File.read(config[c]) if File.exist?(config[c])
          else
            config[c]
          end
        end

        def find_image(image_ref)
          image = find_matching(compute.images, image_ref)
          raise(ActionFailed, "Image not found") unless image

          debug "Selected image: #{image.id} #{image.name}"
          image
        end

        def find_flavor(flavor_ref)
          flavor = find_matching(compute.flavors, flavor_ref)
          raise(ActionFailed, "Flavor not found") unless flavor

          debug "Selected flavor: #{flavor.id} #{flavor.name}"
          flavor
        end

        def find_network(network_ref)
          net = find_matching(network.networks.all, network_ref)
          raise(ActionFailed, "Network not found") unless net

          debug "Selected net: #{net.id} #{net.name}"
          net
        end

        def find_matching(collection, name)
          name = name.to_s
          if name.start_with?("/") && name.end_with?("/")
            regex = Regexp.new(name[1...-1])
            # check for regex name match
            collection.each { |single| return single if regex&.match?(single.name) }
          else
            # check for exact id match
            collection.each { |single| return single if single.id == name }
            # check for exact name match
            collection.each { |single| return single if single.name == name }
          end
          nil
        end
      end
    end
  end
end
