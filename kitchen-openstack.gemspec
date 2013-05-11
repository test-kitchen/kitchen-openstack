# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/openstack_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-openstack'
  spec.version       = Kitchen::Driver::OPENSTACK_VERSION
  spec.authors       = ['Jonathan Hartman']
  spec.email         = ['j@p4nt5.com']
  spec.description   = %q{A Test Kitchen OpenStack Nova driver}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/RoboticCheese/kitchen-openstack'
  spec.license       = 'Apache'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen', '~> 1.0.0.alpha'
  spec.add_dependency 'fog'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'tailor'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'countloc'
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
