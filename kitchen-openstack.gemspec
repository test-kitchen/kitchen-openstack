# Encoding: UTF-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
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

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "test-kitchen", ">= 1.4.1", "< 3"
  spec.add_dependency "fog-openstack", "~> 0.1"
  spec.add_dependency "unf"
  spec.add_dependency "ohai"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "chefstyle"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "countloc"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-console"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "github_changelog_generator"
end
