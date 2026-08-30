# frozen_string_literal: true

#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright:: (C) 2013-2015, Jonathan Hartman
# Copyright:: (C) 2015-2021, Chef Software Inc
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
  # Version string for OpenStack Kitchen driver
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  module Driver
    # The kitchen-openstack gem version.
    #
    # Read by the gemspec and bumped by Release Please, so it must stay a
    # plain string literal on a single line.
    #
    # @return [String]
    OPENSTACK_VERSION = "8.1.0"
  end
end
