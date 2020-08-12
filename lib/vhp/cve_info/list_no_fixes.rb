require_relative '../paths'
require_relative '../yml_helper'

module VHP
  class ListNoFixes
    include Paths
    include YMLHelper

    def nofix(fix_entry)
      return true if fix_entry.nil? || fix_entry.empty?
      fixes = fix_entry.map { |fix| fix[:commit] }
      fixes = fixes.reject {|f| f.to_s.empty? }
      return fixes.size == 0
    end


    def run
      cve_ymls.each do |yml_file|
        begin
          yml = load_yml_the_vhp_way(yml_file)
          puts yml[:CVE] if nofix(yml[:fixes])
        rescue => e
          puts "ERROR on #{yml_file}"
          puts e.backtrace
        end
      end
    end

  end
end
