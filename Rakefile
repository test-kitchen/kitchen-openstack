# Encoding: UTF-8
# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "chefstyle"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

desc "Display LOC stats"
task :loc do
  puts "\n## LOC Stats"
  sh "countloc -r lib/kitchen"
end

RSpec::Core::RakeTask.new(:spec)

task default: %i{rubocop loc spec}
