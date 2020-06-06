require 'yaml'
require_relative '../utils/helper'
module VHP
  class Validator
    def initialize(options)
      @dir = VHP.handle_cves(options)
    end

    def validate_ymls
      dir = @dir+ '/*.yml'
      Dir.glob(dir) do |file_path|
        file_txt = VHP.read_file(file_path)
        begin
          Psych.parse(file_txt, file_path)
          puts '.'
        rescue Psych::SyntaxError => ex
          puts 'Validation failed:' + ex.message
        end
      end
      puts 'Done'
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
