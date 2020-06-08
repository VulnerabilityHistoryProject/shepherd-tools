require 'rspec/core/rake_task'

desc 'Defaults to running tests and then installing'
task :default => [:test, :install]

desc 'Install the gem locally'

task :install do
  system('gem build vhp.gemspec')
  system('gem install vhp')
end


desc 'Run unit tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run unit tests'
task :test => :spec
