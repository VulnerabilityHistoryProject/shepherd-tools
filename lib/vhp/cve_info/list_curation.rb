require 'yaml'
require_relative '../utils/helper'
module VHP
  class ListCuration
    def initialize(options)
      @dir = VHP.handle_cves(options)
      @csv_path = nil
      if options.key? 'csv'
        @csv_path = VHP.handle_csv(options['csv'])
      end
    end

    def find_curated(curated = true)
      dir = @dir + '/*.yml'
      begin
        unless @csv_path.nil?
          if curated
            path = File.join(@csv_path, 'curated.csv')
          else
            path = File.join(@csv_path, 'uncurated.csv')
          end
          csv = File.open(path, "w+")
        end
        Dir.glob(dir) do |file|
          open_file = VHP.read_file(file)
          yml = YAML.load(open_file)
          if yml['curated'] == curated
            if curated
              puts 'Curated: ' + file
              unless @csv_path.nil?
                csv.write(file + "\n")
              end
            else
              puts 'Uncurated: ' + file
              unless @csv_path.nil?
                csv.write(file + "\n")
              end
            end
          end
        end
      rescue Exception => ex
        puts ex.message
      ensure
        csv.close unless csv.nil?
      end
    end
  end
end
