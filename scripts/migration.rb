require 'yaml'
# Insert multiple lines into all yml files in a directory
def insert_lines_dir(dir_path, line_above_regex, text_file)
  validate_yml(text_file, read_file(text_file))
  validate_ymls(dir_path)
  # replace tabs with spaces
  text = read_file(text_file)
  text = text.gsub(/\t/,'  ')
  regex = /#{line_above_regex}/
  dir_path = dir_path + '/*.yml'
  puts dir_path
  Dir.glob(dir_path) do |file|
    #puts "file: " + file.to_s
    insert_line(regex, text, file)
  end
end


# inserts a single line into all yml files in a directory
# Not used
def insert_line_dir(line_above_regex, text, dir_path)
  regex = /#{line_above_regex}/
  dir_path = dir_path + '/*.yml'
  puts dir_path
  Dir.glob(dir_path) do |file|
    insertLine(regex, text, file)
  end
end


# inserts lines into a single file
def insert_line(regex, text, file_path)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.each_line do |line|
    newymltxt << line
    if(regex.match(line))
      newymltxt << "\n" + text + "\n"
    end
  end
  save_yml(file_path, newymltxt)
end


# Get the lines you want to insert into file line by line
# No longer used
def read_input_lines()
  puts "Enter your input. When finished press \'Tab\' then \'Enter'\."
  #detect a tab with an enter and remove them from the end
  input = gets("\t\n").chomp("\t\n")
  input
end


def read_file(file_path)
  if File.file?(file_path)
    return File.read(file_path).chomp
  else
    return nil
  end
end

def validate_ymls(dir_path)
  dir_path = dir_path + '/*.yml'
  Dir.glob(dir_path) do |file_path|
    file_txt = read_file(file_path)
    begin
      Psych.parse(file_txt, file_path)
    rescue Psych::SyntaxError => ex
      abort("Migration failed:" + ex.message)
    end
  end
end

def validate_yml(file_path, txt)
  begin
    Psych.parse(txt, file_path)
  rescue Psych::SyntaxError => ex
    abort("Migration failed:" + ex.message)
  end
end


def save_yml(file_path, txt)
  begin
    Psych.parse(txt, file_path)
    File.open(file_path, 'w+') {|f| f.write(txt)}
      puts "Migrated: " + file_path
  rescue Psych::SyntaxError => ex
    puts ex.message
  end
end

=begin
# Deep clone ARGV and clear so gets works properly
dir_path = ""
args = []
ARGV.each {|str| args.push(str)}
ARGV.clear

# Process first arg
if(File.directory?(args[0]))
  dir_path = args[0]
else
  abort("Invalid first argument. Please use a valid directory name")
end

# Process second arg
regex = args[1]

# Process third arg
input = ""
if(args[2].casecmp?("manual"))
  input = readInputLines()
elsif(File.file?(args[2]))
  input = read_file(args[2])
else
  abort("Invalid third argument. Please use either a file name or \'manual\'")
end

# User warning
puts "WARNING: PLEASE BACKUP ALL CVES IN CHOSEN DIRECTORY BEFORE USING THIS SCRIPT"
puts "Remember to manually add the text to the skeleton file"
puts "Take care in making sure your regex is unique to the line above the
insertion point. If not, the text may be inserted multiple times"
puts "Close all .yml file before running this script"
puts "Make sure the regex is within quotes"
puts "Would you still like to run this script? (Y|N)"
continue = gets.chomp
if(continue.casecmp?('y'))
  insert_lines_dir(dir_path, regex, input)
else
  abort("Migration Aborted")
end
=end
