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

require 'ohai' unless defined?(Ohai::System)

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Ohai hints, SSL handling, and server wait helpers
      module Helpers
        private

        def add_ohai_hint(state)
          if bourne_shell?
            info 'Adding OpenStack hint for ohai'
            mkdir_cmd = "sudo mkdir -p #{hints_path}"
            touch_cmd = "sudo bash -c 'echo {} > #{hints_path}/openstack.json'"
            instance.transport.connection(state).execute(
              "#{mkdir_cmd} && #{touch_cmd}"
            )
          elsif windows_os?
            info 'Adding OpenStack hint for ohai'
            touch_cmd = "New-Item #{hints_path}\\openstack.json"
            touch_cmd_args = "-Value '{}' -Force -Type file"
            instance.transport.connection(state).execute(
              "#{touch_cmd} #{touch_cmd_args}"
            )
          end
        end

        def hints_path
          Ohai.config[:hints_path][0]
        end

        def disable_ssl_validation
          require 'excon' unless defined?(Excon)
          Excon.defaults[:ssl_verify_peer] = false
        end

        def wait_for_server(state)
          if config[:server_wait]
            info "Sleeping for #{config[:server_wait]} seconds to let your server start up..."
            countdown(config[:server_wait])
          end
          info 'Waiting for server to be ready...'
          instance.transport.connection(state).wait_until_ready
        rescue
          error "Server #{state[:hostname]} (#{state[:server_id]}) not reachable. Destroying server..."
          destroy(state)
          raise
        end

        def countdown(seconds)
          date1 = Time.now + seconds
          while Time.now < date1
            Kernel.print '.'
            sleep 10
          end
        end
      end
    end
  end
end
