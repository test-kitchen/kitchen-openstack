require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:unit)

desc "Run all test suites"
task test: [:unit]

desc "Run the Test Kitchen integration suites against fog-openstack's mocks"
task :integration do
  # test/fog_mock.rb has to be loaded before Test Kitchen instantiates the
  # driver, hence -r rather than anything inside kitchen.yml.
  sh "bundle exec ruby -Itest -r fog_mock -S kitchen test"
end

desc "Run the unit tests with coverage reporting to coverage/"
task :coverage do
  ENV["COVERAGE"] = "1"
  Rake::Task[:unit].invoke
end

begin
  require "cookstyle"
  desc "Run cookstyle with chefstyle rules"
  task :style do
    sh "cookstyle --chefstyle --display-cop-names"
  end
rescue LoadError
  puts "cookstyle is not available.  gem install cookstyle to do style checking."
end

begin
  require "yard"
  YARD::Rake::YardocTask.new(:yard)

  desc "List methods missing YARD documentation"
  task :yard_stats do
    sh "yard stats --list-undoc"
  end
rescue LoadError
  puts "yard is not available.  gem install yard to generate documentation."
end

desc "Run all quality tasks"
task quality: %i{style}

task default: %i{test quality}
