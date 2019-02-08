class InsertionAlg
  attr_reader :regex, :text, :dir_path, :validate
  attr_accessor :Alg
  def initialize(regex, text, dir_path, validate, alg)
    @regex = regex
    @text = text
    @dir_path = dir_path
    @validate = validate
    @alg = alg
  end

  def run
    @alg.run(self)
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
end

class InsertTextAfter
  # inserts lines after regex in a file
  def run(context)
    Dir.glob(context.dir_path) do |file_path|
      newymltxt = ""
      file = File.open(file_path, "r")
      file.each_line do |line|
        newymltxt << line
        if(context.regex.match(line))
          newymltxt << context.text
        end
      end
      context.save_yml(file_path, newymltxt, context.validate)
    end
  end
end

class InsertTextBefore
  # inserts lines before regex in a file
  def run(context)
    Dir.glob(context.dir_path) do |file_path|
      newymltxt = ""
      file = File.open(file_path, "r")
      file.reverse_each do |line|
        newymltxt =  line + newymltxt
        if(context.regex.match(line))
          newymltxt = context.text + "\n" + newymltxt
        end
      end
      context.save_yml(file_path, newymltxt, context.validate)
    end
  end
end

# replaces the line designated by the regex
class ReplaceText
  def run(context)
    Dir.glob(context.dir_path) do |file_path|
      newymltxt = ""
      file = File.open(file_path, "r")
      file.each_line do |line|
        if(context.regex.match(line))
          newymltxt << context.text + "\n"
        else
          newymltxt << line
        end
      end
      context.save_yml(file_path, newymltxt, context.validate)
    end
  end
end
