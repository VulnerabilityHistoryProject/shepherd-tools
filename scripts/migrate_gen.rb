require_relative 'migration'
require "erb"

class Migrate
  def initialize(dir, regex, insert_file, position)
    @dir = dir
    @regex = regex.gsub("\d", "\\d")
    @insert_file = insert_file
    if(position.casecmp("after"))
      @method = "insert_text_after"
    elsif(position.casecmp("before"))
      @method = "insert_text_before"
    elsif(position.casecmp("replace"))
      @method = "replace_text"
    else
      abort("Please use a valid position")
    end
  end

  def get_binding
    binding
  end

end

def save_script(file_path, file_txt)
  file_path = file_path + ".rb"
  File.open(file_path, 'w+'){|f| f.write(file_txt)}
  puts "Saved: " + file_path
end


# Process first arg
if(File.directory?(ARGV[0]))
  dir = ARGV[0]
else
  abort("Invalid first argument. Please use a valid directory name")
end

# Process second arg
regex = ARGV[1]


# Process third arg
if(File.file?(ARGV[2]))
  file = ARGV[2]
else
  abort("Invalid third argument. Please use a file name")
end

# process fouth arg
position = ARGV[3]

#gen_script(dir, regex, file)
template = read_file("scripts/migrate.rb.erb")
migrate = Migrate.new(dir, regex, file, position)
render = ERB.new(template)
file_name = "migration/" + Time.now.strftime("migrate_%Y_%m_%d_%H_%M")
file_text = render.result(migrate.get_binding)
save_script(file_name, file_text)
