require 'erb'
require 'fileutils'
require 'pathname'
require_relative '../utils/helper.rb'

module ShepherdTools
  class MigrateTemplate
    def initialize(regex, insert_file, dir, validate, filetype)
      @regex = regex
      @insert_file = insert_file
      @validate = validate
      @dir = dir
      @filetype = filetype
    end

    def get_binding
      binding
    end
  end

  class MigrateGenerator
    def gen(args, options)
      regex = args[0]
      insert_file = find_file(args)
      dir = find_dir(options)
      validate = !(options.key? 'voff')
      filetype = filetype(options)
      file_name = Time.now.strftime('migrate_%Y_%m_%d_%H_%M')
      file_text = script_text(regex, insert_file, dir, validate, filetype)
      save_script(file_name, file_text)

      if(options.key? 'run')
        system('ruby migrations/' + file_name + '.rb')
      end
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
        raise 'Error: Invalid second argument. Please use a file name'
      end
      insert_file
    end

    def find_dir(options)
      if(options.key? 'dir')
        dir = options['dir']
        unless(File.directory? dir)
          raise 'Error: Not a valid directory'
        end
      else
        dir = ShepherdTools.find_CVE_dir
      end
      dir
    end

    def script_text(regex, insert_file, dir, validate, filetype)
      template = ShepherdTools.read_file(File.join(File.dirname(__FILE__), 'migrate_template.rb.erb'))
      migrateTemplate = MigrateTemplate.new(regex, insert_file, dir, validate, filetype)
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
