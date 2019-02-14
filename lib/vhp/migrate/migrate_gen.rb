require 'erb'
require 'fileutils'
require 'pathname'
require_relative '../utils/helper.rb'

module ShepherdTools
  class MigrateTemplate
    def initialize(regex, insert_file, dir, command, validate, filetype, regex_end)
      @regex = regex
      @insert_file = insert_file
      @command = command
      @validate = validate
      @dir = dir
      @filetype = filetype
      @regex_end = regex_end
    end

    def get_binding
      binding
    end
  end

  class MigrateGenerator
    def gen(args, options)
      regex = args[0].gsub('\d', '\\d')
      insert_file = find_file(args)
      dir = find_dir(options)
      command = validate_command(args)
      validate = !(options.key? 'voff')
      filetype = filetype(options)
      regex_end = regex_end(options)
      file_name = Time.now.strftime('migrate_%Y_%m_%d_%H_%M')
      file_text = script_text(regex, insert_file, dir, command, validate, filetype, regex_end)
      save_script(file_name, file_text)

      if(options.key? 'run')
        system('ruby migrations/' + file_name + '.rb')
      end
    end

    def regex_end(options)
      if(options.key? 'regex_end')
        regex = options['regex_end']
        regex = regex.gsub('\d', '\\d')
      else
        regex = ""
      end
      regex
    end

    def filetype(options)
      if(options.key? 'filetype')
        filetype = options['filetype']
      else
        filetype = '.yml'
      end
      filetype
    end

    def find_file(args)
      # Canonicalization of path? TODO
      if(File.file?(args[1]))
        insert_file = args[1]
      else
        abort('Invalid second argument. Please use a file name')
      end
      insert_file
    end

    def validate_command(args)
      commands = ['after', 'before', 'replace']
      if(commands.include? args[2].downcase)
        command = args[2]
      else
        abort('Invalid subcommand')
      end
      command
    end

    def find_dir(options)
      if(options.key? 'dir')
        dir = options['dir']
        unless(File.directory? dir)
          abort('Not a valid directory')
        end
      else
        dir = ShepherdTools.find_CVE_dir
      end
      dir
    end

    def script_text(regex, insert_file, dir, command, validate, filetype, regex_end)
      template = ShepherdTools.read_file(File.join(File.dirname(__FILE__), 'migrate_template.rb.erb'))
      migrateTemplate = MigrateTemplate.new(regex, insert_file, dir, command, validate, filetype, regex_end)
      render = ERB.new(template)
      render.result(migrateTemplate.get_binding)
    end

    def save_script(file_name, file_txt)
      dirname = Pathname.new(File.join(Dir.pwd, 'migrations')).cleanpath
      file_name = file_name + '.rb'
      file_path = File.join(dirname, file_name)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(file_path, 'w+'){|f| f.write(file_txt)}
      puts 'Saved: ' + file_path
    end
  end
end
