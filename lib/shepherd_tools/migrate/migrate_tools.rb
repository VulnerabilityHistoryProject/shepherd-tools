require 'yaml'
require_relative '../path_finder'

# Insert multiple lines into all yml files in a directory
def insert_text(regex, text_file, pos)
  dir_path = find_CVE_dir()
  puts dir_path
  validate_ymls(dir_path)
  # replace tabs with spaces
  text = read_file(text_file)
  text = text.gsub(/\t/,'  ')
  regex = /#{regex}/
  dir_path = dir_path + '/*.yml'
  puts dir_path
  if(pos.casecmp?("after"))
    Dir.glob(dir_path) do |file|
      #puts "file: " + file.to_s
      insert_text_after(regex, text, file)
    end
  elsif(pos.casecmp?("before"))
    Dir.glob(dir_path) do |file|
      #puts "file: " + file.to_s
      insert_text_before(regex, text, file)
    end
  elsif(pos.casecmp?("replace"))
    Dir.glob(dir_path) do |file|
      #puts "file: " + file.to_s
      replace_text(regex, text, file)
    end
  else
    abort("Not a valid position")
  end
end

# inserts lines after regex in a file
def insert_text_after(regex, text, file_path)
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

# inserts lines before regex in a file
def insert_text_before(regex, text, file_path)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.reverse_each do |line|
    newymltxt =  line + newymltxt
    if(regex.match(line))
      newymltxt = text + "\n\n" + newymltxt
    end
  end
  save_yml(file_path, newymltxt)
end

# replaces the line designated by the regex
def replace_text(regex, text, file_path)
  newymltxt = ""
  file = File.open(file_path, "r")
  file.each_line do |line|
    if(regex.match(line))
      newymltxt << text + "\n"
    else
      newymltxt << line
    end
  end
  save_yml(file_path, newymltxt)
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

def save_yml(file_path, txt)
  begin
    Psych.parse(txt, file_path)
    File.open(file_path, 'w+') {|f| f.write(txt)}
      puts "Migrated: " + file_path
  rescue Psych::SyntaxError => ex
    puts ex.message
  end
end
