# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/driver/openstack_version"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-openstack"
  spec.version       = Kitchen::Driver::OPENSTACK_VERSION
  spec.authors       = ["Jonathan Hartman", "JJ Asghar"]
  spec.email         = ["j@p4nt5.com", "jj@chef.io"]
  spec.description   = "A Test Kitchen OpenStack Nova driver"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/test-kitchen/kitchen-openstack"
  spec.license       = "Apache-2.0"

  # Named explicitly rather than globbed: Dir[] drops a name it cannot match
  # without complaining, which is how every published gem up to 8.0.0 came to
  # ship no license file at all -- the glob asked for "LICENSE" while the file
  # was named LICENSE.txt. The file is now LICENSE, matching the rest of the
  # test-kitchen plugins.
  spec.files         = %w{LICENSE README.md} + Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://kitchen.ci/docs/drivers/openstack/",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "test-kitchen", ">= 3.0", "< 5"
  spec.add_dependency "fog-openstack", "~> 1.0"
  spec.add_dependency "ohai"
end
