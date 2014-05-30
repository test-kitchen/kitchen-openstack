# Encoding: UTF-8

require 'bundler/setup'
require 'tailor/rake_task'
require 'cane/rake_task'
require 'rspec/core/rake_task'

Cane::RakeTask.new

Tailor::RakeTask.new do |task|
  task.file_set '**/*.rb'
end

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

RSpec::Core::RakeTask.new(:spec)

task :default => [ :cane, :tailor, :loc, :spec ]
