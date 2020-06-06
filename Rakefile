require "rake/testtask"

desc 'Defaults to running tests and then installing'
task :default => [:test, :install]

desc 'Install the gem locally'

task :install do
  system('gem build vhp.gemspec')
  system('gem install vhp')
end


desc 'Run unit tests'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end
