require_relative '../helper'
require_relative 'migration_algs.rb'

module ShepherdTools
  class Migration
    # Insert multiple lines into all yml files in a directory
    def insert_text(regex, insert_file, dir, command, validate, filetype, regex_end)

      puts 'DIR: ' + dir

      dir = dir + '/*' + filetype
      regex = /#{regex}/
      regex_end = /#{regex_end}/
      if(insert_file=='')
        text = ''
      else
        text = ShepherdTools.read_file(insert_file)
      end
      puts command
      puts regex_end.to_s
      if(command.casecmp('after') && regex_end.to_s.empty?)
        alg = MigrationAlg.new(regex, text, dir, validate, regex_end, InsertTextAfter.new)
      elsif(command.casecmp('before') && regex_end.to_s.empty?)
        alg = MigrationAlg.new(regex, text, dir, validate, regex_end, InsertTextBefore.new)
      elsif(command.casecmp('replace') && regex_end.to_s.empty?)
        alg = MigrationAlg.new(regex, text, dir, validate, regex_end, ReplaceText.new)
      elsif(command.casecmp('replace') && !regex_end.to_s.empty?)
        alg = MigrationAlg.new(regex, text, dir, validate, regex_end, ReplaceTextBlock.new)
      else
        abort('Not a valid subcommand')
      end
      alg.run
    end
  end
end
