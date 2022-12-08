# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require_relative 'lib/vhp/version'


Gem::Specification.new do |s|
  s.name        = "vhp"
  s.version     = VHP::VERSION
  s.license     = 'MIT'
  s.date        = "2019-02-05"
  s.summary     = "Tools for VHP"
  s.description = "Tools for the vulnerability history project"
  s.authors     = ["Andy Meneely", "Matt Thyng"]
  s.files       = Dir.glob("{bin,lib}/**/*") + ["README.md"]
  s.homepage    = "https://github.com/VulnerabilityHistoryProject/shepherd-tools"

  s.executables = ["vhp"]

  s.require_path = "lib"

  s.add_runtime_dependency 'mercenary', '0.3.6'
  s.add_runtime_dependency 'mechanize', '~> 2.8.0'
  s.add_runtime_dependency 'git', '1.12.0'
  s.add_runtime_dependency 'parallel', '1.13.0'
  s.add_runtime_dependency 'httparty', '0.17.0'
  s.add_runtime_dependency 'require_all', '3.0.0'
  s.add_runtime_dependency 'os', '1.1.0'
  s.add_runtime_dependency 'ruby-progressbar', '1.10.1'

end
