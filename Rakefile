require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:unit)

desc 'Run all test suites'
task test: [:unit]

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
task quality: %i(style)

task default: %i(test quality)
