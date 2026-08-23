# frozen_string_literal: true

#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright:: (C) 2013-2015, Jonathan Hartman
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

require "fog/openstack"
require "kitchen"

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # A class to allow the Kitchen Openstack driver
      # to use Openstack volumes
      #
      # Instances of this class translate a `block_device_mapping` config hash
      # into the shape Nova expects, creating a Cinder volume first when the
      # mapping asks for one.
      #
      # @author Liam Haworth <liam.haworth@bluereef.com.au>
      class Volume
        # Seconds to wait for a newly created volume to become available when
        # the block device mapping does not specify `creation_timeout`.
        #
        # @return [Integer]
        DEFAULT_CREATION_TIMEOUT = 60

        # Block device mapping keys forwarded verbatim to Cinder's create call.
        #
        # @return [Array<Symbol>]
        VANILLA_VOLUME_OPTIONS = %i{
          snapshot_id
          imageRef
          volume_type
          source_volid
          availability_zone
        }.freeze

        # @param logger [Kitchen::Logger] logger to report volume progress to
        def initialize(logger)
          @logger = logger
        end

        # Builds a Cinder connection.
        #
        # @param openstack_server [Hash] Fog connection settings
        # @return [Fog::OpenStack::Volume] a Cinder service object
        def volume(openstack_server)
          Fog::OpenStack::Volume.new(openstack_server)
        end

        # Creates a Cinder volume and blocks until it is available.
        #
        # @param config [Hash] the driver config, read for `:server_name` and
        #   `:block_device_mapping`
        # @param os [Hash] Fog connection settings
        # @return [String] the id of the newly created volume
        # @raise [Kitchen::ActionFailed] if a timeout is not a number, if the
        #   volume cannot be found after creation, or if it enters an `error`
        #   state
        # @raise [Fog::Errors::TimeoutError] if the volume is not available
        #   before `:creation_timeout` elapses
        def create_volume(config, os)
          bdm = config[:block_device_mapping]

          # Read both timeouts before anything is created. They are pure config
          # parsing, so a bad value should cost the user an error message, not
          # an orphaned volume that `kitchen destroy` cannot see.
          creation_timeout = timeout_value(bdm, :creation_timeout, DEFAULT_CREATION_TIMEOUT)
          attach_timeout = timeout_value(bdm, :attach_timeout, 0)

          opt = VANILLA_VOLUME_OPTIONS.select { |o| bdm[o] }.to_h { |key| [key, bdm[key]] }

          # Build the Cinder connection once and reuse it for the readiness
          # lookup, rather than authenticating to Keystone a second time.
          volume_service = volume(os)

          @logger.info "Creating Volume..."
          resp = volume_service
            .create_volume(
              "#{config[:server_name]}-volume",
              "#{config[:server_name]} volume",
              bdm[:volume_size],
              opt
            )
          vol_id = resp[:body]["volume"]["id"]

          wait_for_volume(volume_service, vol_id, creation_timeout, attach_timeout)

          vol_id
        end

        # Resolves the block device mapping to hand to Nova, creating the
        # backing volume first if `:make_volume` is set.
        #
        # The returned hash is a copy: the driver's own config is never
        # mutated, so a retried `create` sees the same input it did the first
        # time.
        #
        # @param config [Hash] the driver config
        # @param os [Hash] Fog connection settings
        # @return [Hash] a block device mapping suitable for Nova
        def get_bdm(config, os)
          bdm = config[:block_device_mapping].dup
          bdm[:volume_id] = create_volume(config, os) if bdm[:make_volume]
          bdm.delete(:make_volume)
          bdm.delete(:snapshot_id)
          bdm
        end

        private

        # Blocks until the named volume reports ready, then honours any
        # additional `:attach_timeout` grace period.
        #
        # @param volume_service [Fog::OpenStack::Volume] an established Cinder
        #   connection
        # @param vol_id [String] id of the volume to wait on
        # @param creation_timeout [Integer] seconds to wait for readiness
        # @param attach_timeout [Integer] extra seconds to sleep once ready
        # @return [void]
        # @raise [Kitchen::ActionFailed] if the volume cannot be fetched back
        #   or enters an `error` state
        def wait_for_volume(volume_service, vol_id, creation_timeout, attach_timeout)
          # Fetch the volume by id rather than scanning the collection: a list
          # call returns a single page (Cinder caps it at osapi_max_limit), so
          # in a project with more volumes than that the one just created may
          # not appear on it. `get` is a direct GET and returns nil on 404.
          vol_model = volume_service.volumes.get(vol_id)
          raise(ActionFailed, "Volume #{vol_id} disappeared after creation") if vol_model.nil?

          @logger.debug "Waiting for volume to be ready for #{creation_timeout} seconds"
          vol_model.wait_for(creation_timeout) do
            sleep(1)
            raise(ActionFailed, "Failed to make volume #{vol_id}") if status.casecmp("error") == 0

            ready?
          end

          if attach_timeout > 0
            @logger.debug "Sleeping for an additional #{attach_timeout} seconds before attaching volume to wait for Openstack to finish disk creation process.."
            sleep(attach_timeout)
          end

          @logger.debug "Volume Ready"
        end

        # Reads a timeout out of the block device mapping as an Integer.
        #
        # YAML happily parses `attach_timeout: 5` as an Integer but
        # `attach_timeout: "5"` as a String, and comparing a String to 0 raises.
        # Coerce so both spellings work.
        #
        # Base 10 is explicit: a bare `Integer("010")` would read the leading
        # zero as octal and quietly wait 8 seconds instead of 10, and
        # `Integer("08")` would raise outright.
        #
        # @param bdm [Hash] the block device mapping
        # @param key [Symbol] the timeout key to read
        # @param default [Integer] value to use when the key is absent or empty
        # @return [Integer] the timeout in seconds
        # @raise [Kitchen::ActionFailed] if the value is present but not a
        #   number
        def timeout_value(bdm, key, default)
          value = bdm[key]
          # `attach_timeout:` with nothing after it parses to nil.
          return default if value.nil? || value.to_s.strip.empty?

          begin
            # The base argument is only legal for a String; passing one
            # alongside an Integer raises "base specified for non string value".
            value.is_a?(String) ? Integer(value, 10) : Integer(value)
          rescue ArgumentError, TypeError
            raise(ActionFailed,
              "The block_device_mapping #{key} must be a number, got #{value.inspect}")
          end
        end
      end
    end
  end
end
