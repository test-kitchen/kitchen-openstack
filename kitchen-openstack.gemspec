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

  spec.files         = Dir["LICENSE", "README.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "test-kitchen", ">= 1.4.1", "< 4"
  spec.add_dependency "fog-openstack", "~> 1.0"
  spec.add_dependency "ohai"
end
