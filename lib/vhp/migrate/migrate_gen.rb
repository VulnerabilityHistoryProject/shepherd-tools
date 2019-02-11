require "erb"
require "fileutils"
require 'pathname'
require_relative "../helper.rb"

module ShepherdTools
  class MigrateTemplate
    def initialize(regex, insert_file, position, validate)
      @regex = regex
      @insert_file = insert_file
      @position = position
      @validate = validate
    end

    def get_binding
      binding
    end
  end

  class MigrateGenerator
    def gen(args, validate, run)
      regex = args[0].gsub("\d", "\\d")

      # Canonicalization of path? TODO
      if(File.file?(args[1]))
        insert_file = args[1]
      else
        abort("Invalid second argument. Please use a file name")
      end

      positions = ["after", "before", "replace"]
      if(positions.include? args[2].downcase)
        position = args[2]
      else
        abort("Invalid third argument. Please use after, before or replace.")
      end

      template = ShepherdTools.read_file(File.join(File.dirname(__FILE__),'migrate.rb.erb'))
      migrateTemplate = MigrateTemplate.new(regex, insert_file, position, validate)
      render = ERB.new(template)
      file_name = Time.now.strftime("migrate_%Y_%m_%d_%H_%M")
      file_text = render.result(migrateTemplate.get_binding)
      save_script(file_name, file_text)
      if(run)
        system("ruby migrations/" + file_name + ".rb")
      end
    end

    def save_script(file_name, file_txt)
      dirname = Pathname.new(File.join(Dir.pwd, 'migrations')).cleanpath
      file_name = file_name + ".rb"
      file_path = File.join(dirname, file_name)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(file_path, 'w+'){|f| f.write(file_txt)}
      puts "Saved: " + file_path
    end
  end
end
