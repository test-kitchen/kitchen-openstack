# Encoding: UTF-8

require 'bundler/setup'
require 'rspec/core/rake_task'

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

RSpec::Core::RakeTask.new(:spec)

task default: [:cane, :rubocop, :loc, :spec]
