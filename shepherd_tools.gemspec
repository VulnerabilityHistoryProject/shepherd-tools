# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require_relative 'lib/shepherd_tools/version'


Gem::Specification.new do |s|
  s.name        = "shepherd_tools"
  s.version     = ShepherdTools::VERSION
  s.license     = 'MIT'
  s.date        = "2019-02-05"
  s.summary     = "Tools for VHP"
  s.description = "Tools for the vulnerability history project"
  s.authors     = ["Matt Thyng"]
  s.files       = Dir.glob("{bin,lib}/**/*") + ["README.md"]
  s.homepage    = "https://github.com/VulnerabilityHistoryProject/shepherd-tools"

  s.executables = ["shepherd_tools"]

  s.require_path = "lib"

  s.add_runtime_dependency 'mercenary', '0.3.6'

  s.add_runtime_dependency 'bundler'
end
