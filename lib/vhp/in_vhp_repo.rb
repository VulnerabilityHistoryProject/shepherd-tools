# Are we in a VHP project?
# This gets run from our CLI to make sure we are in the right place
module VHP::InVHPRepo
  module_function def check_in_vhp_repo
    in_repo = true
    in_repo &&= File.exist? 'project.yml'
    in_repo &&= Dir.exist? 'commits'
    in_repo &&= Dir.exist? 'cves'
    in_repo &&= Dir.exist? 'skeletons'
    unless in_repo
      warn <<~EOS
        WARNING! Looks like you are not in a VHP *-vulnerabilities repo.
        For `vhp` to work properly, you need to be at the root of the repo.
      EOS
    end
  end
end
