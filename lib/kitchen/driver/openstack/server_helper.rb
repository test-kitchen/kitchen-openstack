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
        # Config keys copied onto the server definition when set, each routed
        # through {#optional_config}.
        #
        # @return [Array<Symbol>]
        OPTIONAL_SERVER_KEYS = %i{
          security_groups
          key_name
          user_data
          config_drive
          metadata
        }.freeze

        private

        # Builds the Nova server definition and submits it.
        #
        # Fog's `bootstrap`/`setup` helpers are deliberately not used: they
        # require a public IP address, which is not guaranteed to exist on
        # every OpenStack deployment.
        #
        # @return [Fog::OpenStack::Compute::Server] the newly created server
        # @raise [Kitchen::ActionFailed] on mutually exclusive or unresolvable
        #   configuration
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

          OPTIONAL_SERVER_KEYS.each do |c|
            server_def[c] = optional_config(c) if config[c]
          end

          if config[:cloud_config]
            raise(ActionFailed, "Cannot specify both cloud_config and user_data") if config[:user_data]

            server_def[:user_data] = YAML.dump(Kitchen::Util.stringified_hash(config[:cloud_config])).gsub(/^---\n/, "#cloud-config\n")
          end

          # Last, because this is the only step that creates a resource. Every
          # check above is local config validation, and running them first means
          # a bad security_groups or user_data value cannot strand a Cinder
          # volume whose id exists only in the server_def about to be discarded.
          if config[:block_device_mapping]
            server_def[:block_device_mapping] = get_bdm(config)
          end

          compute.servers.create(server_def)
        end

        # Builds the mandatory part of the server definition.
        #
        # `*_id` and `*_ref` are mutually exclusive: an id is used verbatim, a
        # ref is resolved by name, id or regex through {#find_matching}.
        #
        # @return [Hash] name, image, flavor and availability zone
        # @raise [Kitchen::ActionFailed] if both an id and a ref are given for
        #   the image or the flavor, or if either cannot be resolved
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

        # Resolves one optional server setting to the value Nova expects.
        #
        # @param c [Symbol] the config key
        # @return [Object] the resolved value
        # @raise [Kitchen::ActionFailed] if `:security_groups` is not a list, or
        #   if the `:user_data` file does not exist
        def optional_config(c)
          case c
          when :security_groups
            unless config[c].is_a?(Array)
              raise ActionFailed, "The security_groups config must be an array, got #{config[c].class}"
            end

            config[c]
          when :user_data
            # Booting without the user_data the user asked for produces a
            # server that looks fine and behaves wrongly, so a missing file is
            # fatal rather than silently ignored.
            unless File.exist?(config[c])
              raise ActionFailed, "The user_data file <#{config[c]}> does not exist"
            end

            File.read(config[c])
          else
            config[c]
          end
        end

        # Finds a Glance image by id, name or regex.
        #
        # @param image_ref [String] id, name, or `/regex/`
        # @return [Object] the matching image
        # @raise [Kitchen::ActionFailed] if nothing matches
        def find_image(image_ref)
          image = find_matching(compute.images, image_ref)
          raise(ActionFailed, "Image not found") unless image

          debug "Selected image: #{image.id} #{image.name}"
          image
        end

        # Finds a Nova flavor by id, name or regex.
        #
        # @param flavor_ref [String] id, name, or `/regex/`
        # @return [Object] the matching flavor
        # @raise [Kitchen::ActionFailed] if nothing matches
        def find_flavor(flavor_ref)
          flavor = find_matching(compute.flavors, flavor_ref)
          raise(ActionFailed, "Flavor not found") unless flavor

          debug "Selected flavor: #{flavor.id} #{flavor.name}"
          flavor
        end

        # Finds a Neutron network by id, name or regex.
        #
        # @param network_ref [String] id, name, or `/regex/`
        # @return [Object] the matching network
        # @raise [Kitchen::ActionFailed] if nothing matches
        def find_network(network_ref)
          net = find_matching(network.networks.all, network_ref)
          raise(ActionFailed, "Network not found") unless net

          debug "Selected net: #{net.id} #{net.name}"
          net
        end

        # Picks a resource out of a Fog collection.
        #
        # A ref wrapped in forward slashes is treated as a regular expression
        # matched against the resource name; anything else is compared against
        # the id first and then the name, so an exact id always wins.
        #
        # @example an exact name
        #   find_matching(compute.images, "ubuntu-24.04")
        # @example a regular expression
        #   find_matching(compute.images, "/^ubuntu-24\\.04/")
        #
        # @param collection [Enumerable] the Fog collection to search
        # @param name [String] id, name, or `/regex/`
        # @return [Object, nil] the first match, or nil
        # @raise [Kitchen::ActionFailed] if the ref looks like a regex but is
        #   not a valid one
        def find_matching(collection, name)
          name = name.to_s
          # A one-character "/" starts and ends with a slash, but the pattern
          # between the slashes is empty and an empty Regexp matches the first
          # resource in the collection -- which is never what anyone meant.
          if name.length > 1 && name.start_with?("/") && name.end_with?("/")
            regex = compile_ref_regex(name)
            # check for regex name match, skipping unnamed resources; Neutron
            # networks in particular are allowed to have no name
            collection.each { |single| return single if single.name && regex.match?(single.name) }
          else
            # check for exact id match; ids come back as integers on some
            # deployments, so compare as strings
            collection.each { |single| return single if single.id.to_s == name }
            # check for exact name match
            collection.each { |single| return single if single.name == name }
          end
          nil
        end

        # Compiles the pattern out of a `/regex/` style ref.
        #
        # An unbalanced bracket or a stray quantifier is a typo in kitchen.yml,
        # not a bug in the driver, so it is reported as configuration the user
        # can go and fix rather than as a raw RegexpError backtrace from the
        # middle of a create.
        #
        # @param name [String] the ref, slashes included
        # @return [Regexp] the compiled pattern
        # @raise [Kitchen::ActionFailed] if the pattern does not compile
        def compile_ref_regex(name)
          Regexp.new(name[1...-1])
        rescue RegexpError => e
          raise ActionFailed, "Could not parse <#{name}> as a regular expression: #{e.message}"
        end
      end
    end
  end
end
