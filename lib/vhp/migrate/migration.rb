require 'yaml'
require_relative '../helper'
require_relative 'insertion_algs.rb'

module ShepherdTools
  class Migration
    # Insert multiple lines into all yml files in a directory
    def insert_text(regex, insert_file, position, validate)

      dir_path = '../cves/'
      puts 'CVE DIR: ' + dir_path

      dir_path = dir_path + '/*.yml'
      regex = /#{regex}/
      if(insert_file=='')
        text = ''
      else
        text = ShepherdTools.read_file(insert_file)
      end

      case position
      when 'after'
        alg = InsertionAlg.new(regex, text, dir_path, validate, InsertTextAfter.new)
      when 'before'
        alg = InsertionAlg.new(regex, text, dir_path, validate, InsertTextBefore.new)
      when 'replace'
        alg = InsertionAlg.new(regex, text, dir_path, validate, ReplaceText.new)
      else
        abort('Not a valid position')
      end
      alg.run
    end
  end
end
