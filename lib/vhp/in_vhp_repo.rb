# Are we in a VHP project?
# This gets run from our CLI to make sure we are in the right place
module VHP::InVHPRepo
  module_function def check_in_vhp_repo
    missing_files = []

    check_missing! missing_files, 'project.yml'
    check_missing! missing_files, 'commits/gitlog.json'
    check_missing! missing_files, 'cves'
    check_missing! missing_files, 'skeletons/cve.yml'

    unless missing_files.empty?
      warn <<~EOS
        WARNING! Looks like you are not in a VHP *-vulnerabilities repo.
        For `vhp` to work properly, you need to be at the root of the repo.
        Missing files: #{missing_files}
      EOS
    end
    return missing_files.empty?
  end

  def self.check_missing!(missing_files, file)
    missing_files << file unless File.exist? file
  end


end
