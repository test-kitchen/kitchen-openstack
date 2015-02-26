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

require 'fog'
require 'kitchen'

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::SSHBase
      # A class to allow the Kitchen Openstack driver
      # to use Openstack volumes
      #
      # @author Liam Haworth <liam.haworth@bluereef.com.au>
      class Volume
        def volume(openstack_server)
          Fog::Volume.new(openstack_server)
        end

        def volume_ready?(vol_id, os)
          resp = volume(os).get_volume_details(vol_id)
          status = resp[:body]['volume']['status']
          fail "Failed to make volume <#{vol_id}>" if status == 'error'
          status == 'available'
        end

        def create_volume(config, os)
          opt = {}
          bdm = config[:block_device_mapping]
          vanilla_options = [:snapshot_id, :imageRef, :volume_type,
                             :source_volid, :availability_zone]
          vanilla_options.select { |o| bdm[o] }.each do |key|
            opt[key] = bdm[key]
          end
          resp = volume(os).create_volume("#{config[:server_name]}-volume",
                                          "#{config[:server_name]} volume",
                                          bdm[:volume_size],
                                          opt)
          vol_id = resp[:body]['volume']['id']
          sleep(1) until volume_ready?(vol_id, os)
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
