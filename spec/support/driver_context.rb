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

require "logger"
require "stringio" unless defined?(StringIO)

# Shared setup for every example that needs a configured driver.
#
# Provides:
#   config        - the hash handed to Kitchen::Driver::Openstack.new (override with `let`)
#   driver        - the driver under test, with `instance` stubbed to `instance`
#   instance      - a stand-in Kitchen::Instance
#   logged_output - a StringIO holding everything the driver logged
#
# The driver's `sleep` is neutered so no example ever waits on the wall clock.
RSpec.shared_context "with a configured driver" do
  let(:logged_output) { StringIO.new }
  let(:logger)        { Logger.new(logged_output) }
  let(:instance_name) { "potatoes" }
  let(:transport)     { Kitchen::Transport::Dummy.new }
  let(:platform)      { Kitchen::Platform.new(name: "fake_platform") }
  let(:config)        { {} }

  let(:instance) do
    instance_double(
      Kitchen::Instance,
      name: instance_name,
      transport: transport,
      logger: logger,
      platform: platform,
      to_str: "instance"
    )
  end

  let(:driver) do
    Kitchen::Driver::Openstack.new(config).tap do |d|
      allow(d).to receive_messages(instance: instance, sleep: 0)
    end
  end

  # Replaces ENV wholesale with a copy that has no OS_* variable in it, plus
  # whatever the caller passes.
  #
  # Stubbing individual lookups was not enough: a developer with OS_CLOUD or
  # OS_USERNAME exported got different results from CI. Examples that need a
  # variable set opt in by passing it here.
  #
  # @param vars [Hash{String => String}] variables to add back
  # @return [Hash] the stubbed ENV
  def stub_env(vars = {})
    stub_const("ENV", ENV.to_h.reject { |k, _| k.start_with?("OS_") }.merge(vars))
  end

  before do
    # Re-declare File.exist? as a partial double so that per-example `.with`
    # stubs can be layered on it without breaking every unrelated caller. On
    # its own this changes nothing -- real filesystem behavior is preserved.
    allow(File).to receive(:exist?).and_call_original

    # This is what actually isolates the suite from the developer's machine:
    # with no OS_* variables in scope, no clouds.yaml lookup can be triggered
    # by ambient environment. Note that it does not, by itself, stop the
    # clouds.yaml *search path* from reaching real files -- the specs that
    # exercise that search pin Dir.pwd, Dir.home and /etc/openstack as well.
    stub_env
  end
end
