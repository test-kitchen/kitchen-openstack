require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:unit)

desc 'Run all test suites'
task test: [:unit]

desc 'Display LOC stats'
task :stats do
  puts "\n## Production Code Stats"
  sh 'countloc -r lib'
  puts "\n## Test Code Stats"
  sh 'countloc -r spec'
end

begin
  require 'cookstyle'
  desc 'Run cookstyle with chefstyle rules'
  task :style do
    sh 'cookstyle --chefstyle --display-cop-names'
  end
rescue LoadError
  puts 'cookstyle is not available.  gem install cookstyle to do style checking.'
end

desc 'Run all quality tasks'
task quality: %i(style stats)

task default: %i(test quality)
