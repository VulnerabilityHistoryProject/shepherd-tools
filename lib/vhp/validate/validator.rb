require 'yaml'
require_relative "../helper"
module ShepherdTools
  class Validator
    def validate_ymls
      dir_path = '../cves/*.yml'
      Dir.glob(dir_path) do |file_path|
        file_txt = ShepherdTools.read_file(file_path)
        begin
          Psych.parse(file_txt, file_path)
        rescue Psych::SyntaxError => ex
          puts "Validation failed:" + ex.message
        end
      end
      puts "Done"
    end

    def validate_yml(txt, file_path)
      begin
        Psych.parse(txt, file_path)
      rescue Psych::SyntaxError => ex
        puts ex.message
      end
    end
  end
end
