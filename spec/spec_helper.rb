# Encoding: UTF-8

require 'rspec'
require 'simplecov'
require 'simplecov-console'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]
SimpleCov.minimum_coverage 95
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
end
