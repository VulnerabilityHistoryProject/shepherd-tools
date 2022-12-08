require 'rspec'
require 'byebug'
require_relative '../lib/vhp'

def foo_dir
  return File.expand_path("#{__dir__}/../testdata/vulnerabilities")
end

def mining_dir
  return File.expand_path("#{__dir__}/../testdata/vhp-mining")
end

def this_repo
  return File.expand_path("#{__dir__}/..")
end

def cve_1984_0519_file
  "#{foo_dir}/cves/CVE-1984-0519.yml"
end

def silently
  # Store the original stderr and stdout in order to restore them later
  @original_stderr = $stderr
  @original_stdout = $stdout

  # Redirect stderr and stdout
  $stderr = $stdout = StringIO.new

  yield

  $stderr = @original_stderr
  $stdout = @original_stdout
  @original_stderr = nil
  @original_stdout = nil
end
