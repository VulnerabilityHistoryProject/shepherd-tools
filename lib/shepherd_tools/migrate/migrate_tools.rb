require 'yaml'
require_relative '../path_finder'

# Insert multiple lines into all yml files in a directory
def insert_text(regex, insert_file, position, validate)

  dir_path = find_CVE_dir()
  puts "CVE DIR: " + dir_path

  dir_path = dir_path + '/*.yml'
  regex = /#{regex}/
  if(insert_file=="")
    text = ""
  else
    text = read_file(insert_file)
  end

  # Go through the directory and insert the text from the given file
  # WET?? I may want to refactor this
  case position
  when "after"
    Dir.glob(dir_path) do |file|
      insert_text_after(regex, text, file, validate)
    end
  when "before"
    Dir.glob(dir_path) do |file|
      insert_text_before(regex, text, file, validate)
    end
  when "replace"
    Dir.glob(dir_path) do |file|
      replace_text(regex, text, file, validate)
    end
  else
    abort("Not a valid position")
  end
end

# inserts lines after regex in a file
def insert_text_after(regex, text, file_path, validate)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.each_line do |line|
    newymltxt << line
    if(regex.match(line))
      newymltxt << text
    end
  end
  save_yml(file_path, newymltxt, validate)
end

# inserts lines before regex in a file
def insert_text_before(regex, text, file_path, validate)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.reverse_each do |line|
    newymltxt =  line + newymltxt
    if(regex.match(line))
      newymltxt = text + "\n" + newymltxt
    end
  end
  save_yml(file_path, newymltxt, validate)
end

# replaces the line designated by the regex
def replace_text(regex, text, file_path, validate)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.each_line do |line|
    if(regex.match(line))
      newymltxt << text + "\n"
    else
      newymltxt << line
    end
  end
  save_yml(file_path, newymltxt, validate)
end

def read_file(file_path)
  if File.file?(file_path)
    return File.read(file_path).chomp
  else
    return nil
  end
end

def validate_yml(txt, file_path)
  begin
    Psych.parse(txt, file_path)
  rescue Psych::SyntaxError => ex
    puts ex.message
  end
end

def save_yml(file_path, txt, validate)
  if(validate)
    validate_yml(txt, file_path)
  end
  File.open(file_path, 'w+') {|f| f.write(txt)}
  puts "Migrated: " + file_path
end
