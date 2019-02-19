namespace :install do
  task :gem do
    system('gem build vhp.gemspec')
    system('gem install vhp')
  end
end
