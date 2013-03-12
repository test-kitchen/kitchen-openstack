require 'bundler/gem_tasks'
require 'tailor/rake_task'
require 'cane/rake_task'

desc 'Run Cane to check quality metrics'
Cane::RakeTask.new

desc 'Run Tailor to lint check code'
Tailor::RakeTask.new

desc 'Display LOC stats'
task :loc do
  puts "\n## LOC Stats"
  sh 'countloc -r lib/kitchen'
end

task :default => [ :cane, :tailor, :loc ]

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
