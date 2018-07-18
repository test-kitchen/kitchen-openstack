# Encoding: UTF-8

#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013-2015, Jonathan Hartman
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
      # @author Liam Haworth <liam.haworth@bluereef.com.au>
      class Volume
        @@default_creation_timeout = 60

        def initialize(logger)
          @logger = logger
        end

        def volume(openstack_server)
          Fog::Volume.new(openstack_server)
        end

        def create_volume(config, os)
          opt = {}
          bdm = config[:block_device_mapping]
          vanilla_options = %i{snapshot_id imageRef volume_type
                               source_volid availability_zone}
          vanilla_options.select { |o| bdm[o] }.each do |key|
            opt[key] = bdm[key]
          end

          volume_name = "#{config[:server_name]}-volume"

          if bdm[:reuse_volume]
            @logger.info "Attempting to re-use old Volume..."
            volume = volume(os).volumes.find { |x| x.name == volume_name }

            if volume
              if !volume.attachments.empty?
                @logger.info "Volume already attached. Force dettaching ..."
                volume.service.action(volume.id, 'os-reset_status' => {:attach_status => 'detached'})
                volume.reset_status('available')
                volume.wait_for { ready? }
              end
            end

            return volume.id if volume
          end

          @logger.info "Creating Volume..."
          resp = volume(os).create_volume(volume_name,
                                          "#{config[:server_name]} volume",
                                          bdm[:volume_size],
                                          opt)
          vol_id = resp[:body]["volume"]["id"]

          # Get Volume Model to make waiting for ready easy
          vol_model = volume(os).volumes.first { |x| x.id == vol_id }

          # Use default creation timeout or user supplied
          creation_timeout = @@default_creation_timeout
          if bdm.key?(:creation_timeout)
            creation_timeout = bdm[:creation_timeout]
          end

          @logger.debug "Waiting for volume to be ready for #{creation_timeout} seconds"
          vol_model.wait_for(creation_timeout) do
            sleep(1)
            raise("Failed to make volume") if status.casecmp("error".downcase) == 0
            ready?
          end

          @logger.debug "Volume Ready"

          vol_id
        end

        def get_bdm(config, os)
          bdm = config[:block_device_mapping]
          bdm[:volume_id] = create_volume(config, os) if bdm[:make_volume]
          bdm.delete_if { |k, _| k == :make_volume }
          bdm.delete_if { |k, _| k == :snapshot_id }
          bdm
        end
      end
    end
  end
end
