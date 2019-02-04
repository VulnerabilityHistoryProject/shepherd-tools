require_relative 'migration'

def gen_script(dir, regex, insert_file)
  regex = regex.gsub("\d", "\\d")
  file_txt = "require_relative \'../scripts/migration\'\n\n"
  file_name = Time.now.strftime("migrate_%Y_%m_%d_%H_%M")
  file_path = "..\\migration" + "\\" + file_name
  file_txt = file_txt +
    "def " + file_name + "\n" + "\t" +
    "insert_lines_dir(\"" + dir + "\",\"" +  regex + "\",\"" + insert_file + "\")" +
    "\nend\n\n" +
    file_name + "()"
  save_script(file_path, file_txt)
end

def save_script(file_path, file_txt)
  file_path = file_path + ".rb"
  File.open(file_path, 'w+'){|f| f.write(file_txt)}
  puts "Saved" + file_path
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

gen_script(dir, regex, file)
