require_relative '../utils/helper'
require_relative '../yml_helper'

module VHP
  class CurateReady
    include YMLHelper

    def initialize(project, min_fixes, min_vccs, max_level, full)
      @project = project
      @min_fixes = min_fixes
      @min_vccs = min_vccs
      @max_level = max_level
      @full = full
    end

    def using_csv?
      !@csv_path.nil?
    end

    def print_info
      puts <<~EOS
        === CVES READY TO CURATE FOR #{@project} ===
        CVE\tCURATION_LEVEL\tFIXES\tVCCS#{@full ? "\tFIX_SHAS\tVCC_SHAS" : ''}
      EOS
    end

    def print_readiness
      print_info
      begin
        iterate_over_ymls("cves/#{@project}/*.yml")
      rescue IOError => e
        puts(e)
      end
    end

    def iterate_over_ymls(dir)
      Dir.glob(dir) do |yml_file|
        yml = load_yml_the_vhp_way(yml_file)
        num_fixes = fix_count(yml)
        num_vccs = vcc_count(yml)
        if num_fixes >= @min_fixes && num_vccs >= @min_vccs && yml[:curation_level].to_f <= @max_level
          print <<~EOS
            #{yml[:CVE]}\t#{'%1.1f' % yml[:curation_level].to_f }\t#{num_fixes}\t#{num_vccs}#{full_info(yml)}
          EOS
        end
      end
    end

    def fix_count(yml)
      fixes = yml[:fixes].select { |fix| !fix[:commit].to_s.empty? }
      fixes.count
    end

    def vcc_count(yml)
      vccs = yml[:vccs].select { |vcc| !vcc[:commit].to_s.empty? }
      vccs.count
    end

    def full_info(yml)
      if @full
        return "\t#{yml[:fixes].map{|f| f[:commit] }.join(',')}\t#{yml[:vccs].map{|f| f[:commit] }.join(',')}"
      else
        return ''
      end
    end
  end
end


