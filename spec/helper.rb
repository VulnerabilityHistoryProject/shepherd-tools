require 'rspec'
require_relative '../lib/vhp'

def foo_dir
  return File.expand_path("#{__dir__}/../foo-vulnerabilities")
end
