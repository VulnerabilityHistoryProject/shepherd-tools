require_relative 'migrate_tools'
require "erb"
require "fileutils"

class Migrate
  def initialize(regex, insert_file, position)
    @regex = regex.gsub("\d", "\\d")
    @insert_file = insert_file
    @position = position
  end

  def get_binding
    binding
  end

end

def save_script(file_path, file_txt)
  file_path = file_path + ".rb"
  Dir.chdir(File.dirname(__FILE__))
  dirname = "migrations"
  unless File.directory?(dirname)
    FileUtils.mkdir_p(dirname)
  end
  File.open(file_path, 'w+'){|f| f.write(file_txt)}
  puts "Saved: " + file_path
end


# Process first arg
regex = ARGV[0]


# Process second arg
if(File.file?(ARGV[1]))
  file = ARGV[1]
else
  abort("Invalid third argument. Please use a file name")
end

# process third arg
position = ARGV[2]

#gen_script(regex, file, position)
template = read_file("lib/shepherd_tools/migrate/migrate.rb.erb")
migrate = Migrate.new(regex, file, position)
render = ERB.new(template)
file_name = "migrations/" + Time.now.strftime("migrate_%Y_%m_%d_%H_%M")
file_text = render.result(migrate.get_binding)
save_script(file_name, file_text)
