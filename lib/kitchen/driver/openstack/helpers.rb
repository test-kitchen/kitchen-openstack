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

require "ohai" unless defined?(Ohai::System)

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Ohai hints, SSL handling, and server wait helpers
      module Helpers
        # Seconds between progress dots while counting down.
        #
        # @return [Integer]
        COUNTDOWN_TICK = 10

        private

        # Drops an empty `openstack.json` ohai hint on the new instance so
        # that Chef Infra's ohai run picks up OpenStack metadata.
        #
        # Does nothing on platforms that are neither Bourne-shell nor Windows.
        #
        # @param state [Hash] instance state, used to open a transport session
        # @return [void]
        def add_ohai_hint(state)
          if bourne_shell?
            info "Adding OpenStack hint for ohai"
            mkdir_cmd = "sudo mkdir -p #{hints_path}"
            touch_cmd = "sudo bash -c 'echo {} > #{hints_path}/openstack.json'"
            instance.transport.connection(state).execute(
              "#{mkdir_cmd} && #{touch_cmd}"
            )
          elsif windows_os?
            info "Adding OpenStack hint for ohai"
            touch_cmd = "New-Item #{hints_path}\\openstack.json"
            touch_cmd_args = "-Value '{}' -Force -Type file"
            instance.transport.connection(state).execute(
              "#{touch_cmd} #{touch_cmd_args}"
            )
          else
            debug "Unknown platform shell; skipping the OpenStack ohai hint"
          end
        end

        # The directory ohai reads hint files from.
        #
        # @return [String] the first configured ohai hints path
        def hints_path
          Ohai.config[:hints_path][0]
        end

        # Turns off TLS peer verification for every subsequent Excon request in
        # this process.
        #
        # Called when the `disable_ssl_validation` config key is set, which the
        # user sets directly in kitchen.yml or which is inferred from a
        # `verify: false` entry in clouds.yaml.
        #
        # @return [void]
        def disable_ssl_validation
          require "excon" unless defined?(Excon)
          Excon.defaults[:ssl_verify_peer] = false
        end

        # Blocks until the transport reports the instance is reachable,
        # destroying the instance if it never comes up.
        #
        # A server we cannot reach is a server we cannot clean up later, so the
        # failure path tears it down before re-raising rather than leaking it.
        #
        # @param state [Hash] instance state, containing `:hostname`
        # @return [void]
        # @raise [StandardError] whatever the transport raised, after cleanup
        def wait_for_server(state)
          if config[:server_wait]
            info "Sleeping for #{config[:server_wait]} seconds to let your server start up..."
            countdown(config[:server_wait])
          end
          info "Waiting for server to be ready..."
          instance.transport.connection(state).wait_until_ready
        rescue => e
          error "Server #{state[:hostname]} (#{state[:server_id]}) not reachable: #{e.message}. Destroying server..."
          destroy(state)
          raise
        end

        # Prints a progress dot every {COUNTDOWN_TICK} seconds for the given
        # duration.
        #
        # @param seconds [Integer] how long to wait
        # @return [void]
        def countdown(seconds)
          finish_at = Time.now + seconds
          while Time.now < finish_at
            Kernel.print "."
            sleep COUNTDOWN_TICK
          end
        end
      end
    end
  end
end
