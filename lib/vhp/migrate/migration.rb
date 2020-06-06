require_relative '../utils/helper'

module VHP
  class Migration
    def initialize
      @invalid_ymls = []
    end

    def insert_text(regex, insert_file, dir, validate, filetype)

      puts 'DIR: ' + dir

      dir = dir + '/*' + filetype
      insert_text = ''
      unless insert_file==''
        insert_text = VHP.read_file(insert_file)
      end

      puts "Regex: #{regex.inspect}"
      puts 'Inserting the following text:'
      puts "\n\n**********************************************"
      puts insert_text
      puts "**********************************************\n\n"

      puts "Migrating:"
      Dir.glob(dir) do |file|
        status = '-'
        text = VHP.read_file(file)
        new_text = text.gsub(regex, insert_text)
        unless text.eql? new_text
          if validate && !validate_yml(new_text, file)
            status = 'F'
          else
            status = 'M'
          end
          save_yml(file, new_text)
        end
        print status
      end

      if validate
        puts "\n\nInvalid YAMLS:"
        @invalid_ymls.each {|e| puts e}
      end

    end

    def validate_yml(txt, file_path)
      passed = true
      begin
        Psych.parse(txt, file_path)
      rescue Psych::SyntaxError => e
        @invalid_ymls.push("#{e.message}")
        passed = false
      end
      passed
    end

    def save_yml(file, text)
      File.open(file, 'w+') {|f| f.write(text)}
    end
  end
end
