require 'yaml'
require_relative '../helpers/helper'
module ShepherdTools
  class Finder
    def initialize(options)
      if options.key?('dir')
        @dir = options['dir']
      else
        @dir = ShepherdTools.find_CVE_dir
      end
      unless File.directory? @dir
        abort(@dir + ' is not a valid directory')
      end
    end

    def find_curated(curated = true)
      dir = @dir + '/*.yml'
      Dir.glob(dir) do |file_path|
        file = ShepherdTools.read_file(file_path)
        yml = YAML.load(file)
        if yml['curated'] == curated
          if curated
            puts 'Curated: ' + file_path
          else
            puts 'Uncurated: ' + file_path
          end
        end
      end
    end
  end
end
