require_relative '../utils/helper'
require_relative '../yml_helper'

module VHP
  class CurateReady
    include YMLHelper

    def initialize(options)
      raise '--project required' unless options.key? :project
      @project = options[:project]
      @min_fixes = options[:min_fixes].to_i || 0
      @min_vccs = options[:min_vccs].to_i || 0
      @max_level = options.key?(:max_level) ? options[:max_level].to_f : 10000.0
    end

    def using_csv?
      !@csv_path.nil?
    end

    def print_info
      puts <<~EOS
        === CVES READY TO CURATE FOR #{@project} ===
        CVE\tCURATION_LEVEL\tFIXES\tVCCS
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
            #{yml[:CVE]}\t#{'%1.1f' % yml[:curation_level].to_f }\t#{num_fixes}\t#{num_vccs}
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
  end
end
