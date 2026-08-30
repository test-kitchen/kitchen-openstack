# frozen_string_literal: true

#
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

require "rspec"
require "kitchen"
require "kitchen/driver/openstack"
require "kitchen/provisioner/dummy"
require "kitchen/transport/dummy"
require "kitchen/verifier/dummy"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    # Fail the build when a double stubs a method the real object does not
    # have. This is the single most valuable guard against specs that keep
    # passing after the implementation they describe has been renamed.
    mocks.verify_partial_doubles = true
    mocks.syntax = :expect
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.define_derived_metadata { |meta| meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures) }

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.warnings = false

  config.order = :random
  Kernel.srand config.seed
end
