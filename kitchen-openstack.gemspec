# Encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/openstack_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-openstack'
  spec.version       = Kitchen::Driver::OPENSTACK_VERSION
  spec.authors       = ['Jonathan Hartman']
  spec.email         = ['j@p4nt5.com']
  spec.description   = 'A Test Kitchen OpenStack Nova driver'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/test-kitchen/kitchen-openstack'
  spec.license       = 'Apache'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'test-kitchen', '~> 1.1'
  spec.add_dependency 'fog', '~> 1.18'
  # Newer Fogs throw a warning if unf isn't there :(
  spec.add_dependency 'unf'
  spec.add_dependency 'ohai'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'countloc'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'coveralls'
end
