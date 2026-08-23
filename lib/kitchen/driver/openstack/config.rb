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

require "etc" unless defined?(Etc)
require "socket" unless defined?(Socket)

module Kitchen
  module Driver
    class Openstack < Kitchen::Driver::Base
      # Server naming and configuration helpers
      module Config
        # Longest server name OpenStack will accept without truncating.
        #
        # Every other length in this file is derived from it, so the limit is
        # actually maintained by the code rather than merely documented here.
        #
        # @return [Integer]
        MAX_SERVER_NAME_LENGTH = 63

        # Number of random characters appended to a user-supplied prefix.
        #
        # @return [Integer]
        PREFIX_SUFFIX_LENGTH = 8

        # Longest user-supplied prefix that still leaves room for the
        # separator and the random suffix.
        #
        # @return [Integer]
        MAX_PREFIX_LENGTH = MAX_SERVER_NAME_LENGTH - PREFIX_SUFFIX_LENGTH - 1

        # Character budget for the instance name in a fully generated name.
        #
        # @return [Integer]
        NAME_INSTANCE_LENGTH = 15

        # Character budget for the username in a fully generated name.
        #
        # @return [Integer]
        NAME_USERNAME_LENGTH = 15

        # Number of random characters in a fully generated name.
        #
        # @return [Integer]
        NAME_RANDOM_LENGTH = 7

        # Character budget for the hostname in a fully generated name.
        #
        # Whatever is left once the other three components and the three
        # separators are accounted for.
        #
        # @return [Integer]
        NAME_HOSTNAME_LENGTH =
          MAX_SERVER_NAME_LENGTH - NAME_INSTANCE_LENGTH - NAME_USERNAME_LENGTH - NAME_RANDOM_LENGTH - 3

        # Sets `config[:server_name]` unless the user already supplied one.
        #
        # Called at the top of {Kitchen::Driver::Openstack#create} rather than
        # at config-finalize time so that the random suffix is generated once
        # per converge instead of once per `kitchen` invocation.
        #
        # @return [String] the resolved server name
        def config_server_name
          return config[:server_name] if config[:server_name]

          config[:server_name] = if config[:server_name_prefix]
                                   server_name_prefix(config[:server_name_prefix])
                                 else
                                   default_name
                                 end
        end

        private

        # Generates a unique server name of at most 63 characters.
        #
        #     <instance>-<user>-<host>-<random>
        #          15       15      23      7    + 3 separators = 63
        #
        # @return [String] the generated server name
        def default_name
          [
            instance.name.gsub(/\W/, "")[0, NAME_INSTANCE_LENGTH],
            current_username.gsub(/\W/, "")[0, NAME_USERNAME_LENGTH],
            Socket.gethostname.gsub(/\W/, "")[0, NAME_HOSTNAME_LENGTH],
            Array.new(NAME_RANDOM_LENGTH) { rand(36).to_s(36) }.join,
          ].join("-")
        end

        # Best-effort lookup of the name of the user running Test Kitchen.
        #
        # `Etc.getpwuid` raises `ArgumentError` rather than returning nil when
        # the effective uid has no passwd entry, which is routine inside
        # containers, so both failure modes fall through to `Etc.getlogin` and
        # finally to a placeholder.
        #
        # @return [String] a username, or `"nologin"` if none can be determined
        def current_username
          (Etc.getpwuid&.name || Etc.getlogin || "nologin")
        rescue ArgumentError
          Etc.getlogin || "nologin"
        end

        # Generates a unique server name from a user-supplied prefix.
        #
        #     <prefix>-<random>
        #      max 54      8     + 1 separator = 63
        #
        # Falls back to {#default_name} when the prefix contains nothing usable
        # once non-word characters are stripped.
        #
        # @param server_name_prefix [String] the configured prefix; never
        #   mutated, so the caller's config survives intact
        # @return [String] the generated server name
        def server_name_prefix(server_name_prefix)
          prefix = server_name_prefix.to_s
          if prefix.length > MAX_PREFIX_LENGTH
            warn "Server name prefix too long, truncated to #{MAX_PREFIX_LENGTH} characters"
            prefix = prefix[0, MAX_PREFIX_LENGTH]
          end

          prefix = prefix.gsub(/\W/, "")

          if prefix.empty?
            warn "Server name prefix empty or invalid; using fully generated name"
            default_name
          else
            random_suffix = ("a".."z").to_a.sample(PREFIX_SUFFIX_LENGTH).join
            "#{prefix}-#{random_suffix}"
          end
        end
      end
    end
  end
end
