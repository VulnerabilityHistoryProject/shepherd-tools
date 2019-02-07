require_relative 'migrate_tools'
require "erb"
require "fileutils"
module ShepherdTools
  class Migrate
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

  def self.save_script(file_name, file_txt)
    dirname = Dir.pwd + "/lib/shepherd_tools/migrate/migrations/"
    file_path = dirname + file_name + ".rb"
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.open(file_path, 'w+'){|f| f.write(file_txt)}
    puts "Saved: " + file_path
  end

  def self.gen_migrate(args, validate)
    regex = args[0].gsub("\d", "\\d")

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

    template = read_file("lib/shepherd_tools/migrate/migrate.rb.erb")
    migrate = Migrate.new(regex, insert_file, position, validate)
    render = ERB.new(template)
    file_name = Time.now.strftime("migrate_%Y_%m_%d_%H_%M")
    file_text = render.result(migrate.get_binding)
    save_script(file_name, file_text)
  end
end
