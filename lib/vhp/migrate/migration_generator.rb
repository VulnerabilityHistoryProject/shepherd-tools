require 'fileutils'
require_relative '../paths'

module VHP
  class MigrationGenerator
    include Paths
    def run(name)
      filename = "#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}_#{name}.rb"
      FileUtils.cp migration_template, new_migration(filename)
      puts "Migration #{filename} added to #{migration_dir}"
    end
  end
end
