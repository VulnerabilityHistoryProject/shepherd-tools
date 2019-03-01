require_relative '../utils/helper'

module ShepherdTools
  class CurateReady
    def initialize(options)
      @dir = ShepherdTools.handle_cves(options)
      @print_ready = true
      if options.key? 'unready'
        @print_ready = false
      end
    end

    def print_readiness
      dir = @dir + '/*.yml'
      Dir.glob(dir) do |yml_file|
        yml = File.open(yml_file) { |f| YAML.load(f) }
        any_fix = yml['fixes'].inject(false) do |memo, fix|
          memo || !fix['commit'].to_s.empty? || !fix[:commit].to_s.empty?
        end
        if !yml['curated']
          if any_fix
            puts yml['CVE'] if @print_ready # READY
          else
            puts yml['CVE'] if !@print_ready # NOT READY
          end
        end # if it's already curated, it's "done"
      end
    end
  end
end
