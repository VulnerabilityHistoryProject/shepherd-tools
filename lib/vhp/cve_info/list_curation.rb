require 'yaml'
require_relative '../utils/helper'
module ShepherdTools
  class ListCuration
    def initialize(options)
      @dir = ShepherdTools.handle_cves(options)
    end

    def find_curated(curated = true)
      dir = @dir + '/*.yml'
      Dir.glob(dir) do |file_path|
        file = ShepherdTools.read_file(file_path)
        begin
          yml = YAML.load(file)
          if yml['curated'] == curated
            if curated
              puts 'Curated: ' + file_path
            else
              puts 'Uncurated: ' + file_path
            end
          end
        rescue Exception => ex
          puts ex.message
        end
      end
    end
  end
end
