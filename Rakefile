require 'rspec/core/rake_task'
require 'bundler'

desc 'Defaults to running tests and then installing'
task :default => [:test, :install]

Bundler::GemHelper.install_tasks

desc 'Run unit tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run unit tests'
task :test => :spec
