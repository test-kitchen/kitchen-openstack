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
      # Server naming and configuration helpers
      module Config
        # Set the proper server name in the config
        def config_server_name
          return if config[:server_name]

          config[:server_name] = if config[:server_name_prefix]
                                   server_name_prefix(config[:server_name_prefix])
                                 else
                                   default_name
                                 end
        end

        private

        # Generate what should be a unique server name up to 63 total chars
        # Base name:    15
        # Username:     15
        # Hostname:     23
        # Random string: 7
        # Separators:    3
        # ================
        # Total:        63
        def default_name
          [
            instance.name.gsub(/\W/, "")[0..14],
            ((Etc.getpwuid ? Etc.getpwuid.name : Etc.getlogin) || "nologin").gsub(/\W/, "")[0..14],
            Socket.gethostname.gsub(/\W/, "")[0..22],
            Array.new(7) { rand(36).to_s(36) }.join,
          ].join("-")
        end

        def server_name_prefix(server_name_prefix)
          # Generate what should be a unique server name with given prefix
          # of up to 63 total chars
          #
          # Provided prefix:  variable, max 54
          # Separator:        1
          # Random string:    8
          # ===================
          # Max:              63
          #
          if server_name_prefix.length > 54
            warn "Server name prefix too long, truncated to 54 characters"
            server_name_prefix = server_name_prefix[0..53]
          end

          server_name_prefix.gsub!(/\W/, "")

          if server_name_prefix.empty?
            warn "Server name prefix empty or invalid; using fully generated name"
            default_name
          else
            random_suffix = ("a".."z").to_a.sample(8).join
            server_name_prefix + "-" + random_suffix
          end
        end
      end
    end
  end
end
