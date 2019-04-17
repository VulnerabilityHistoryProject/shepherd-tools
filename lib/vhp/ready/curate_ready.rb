require_relative '../utils/helper'

module ShepherdTools
  class CurateReady
    def initialize(options)
      @dir = ShepherdTools.handle_cves(options)
      @print_ready = true
      if options.key? 'unready'
        @print_ready = false
      end
      @csv_path = nil
      if options.key? 'csv'
        @csv_path = ShepherdTools.handle_csv(options['csv'])
      end
    end

    def print_readiness
      dir = @dir + '/*.yml'
      begin
        unless @csv_path.nil?
          if @print_ready
            path = File.join(@csv_path, 'curated_ready.csv')
          else
            path = File.join(@csv_path, 'curated_unready.csv')
          end
          file = File.open(path, "w+")
        end
        Dir.glob(dir) do |yml_file|
          yml = File.open(yml_file) { |f| YAML.load(f) }
          any_fix = yml['fixes'].inject(false) do |memo, fix|
            memo || !fix['commit'].to_s.empty? || !fix[:commit].to_s.empty?
          end
          if !yml['curated']
            if any_fix
              if @print_ready # READY
                puts yml['CVE']
                unless @csv_path.nil?
                  file.write(yml['CVE'] + "\n")
                end
              end
            else
              if !@print_ready # NOT READY
                puts yml['CVE']
                unless @csv_path.nil?
                  file.write(yml['CVE'] + "\n")
                end
              end
            end
          end # if it's already curated, it's "done"
        end
      rescue IOError => e
        puts(e)
      ensure
        file.close unless file.nil?
      end
    end
  end
end
