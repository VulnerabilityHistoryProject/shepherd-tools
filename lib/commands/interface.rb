require 'mercenary'
require_relative '../scripts/migrate_gen.rb'

module ShepherdTools
  class interface

    def run
      Mercenary.program(:shepherd_tools) do |p|
        p.version ShepherdTools::VERSION
        p.description description = "Tools for the vulnerability history project"
        p.syntax 'shepherd_tools <subcommand> [options]'

        p.command(:new) do |c|
          c.syntax "new PATH"
          c.description "Creates a new Shepherd-Tools scaffold in PATH"
        end

        p.command(:migrate) do |c|
          c.syntax "gen [options]"
          c.description "Migrates CVE YAMLs"

          c.option "validate", "--validate", "Validates YAMLs as you migrate"
          c.option "posistion", "--pos Postion", "Where the text will be inserted relative to the regex. Options are AFTER, BEFORE and REPLACE"

          c.action do |posistion|
            #Not currently working
            #ShepherdTools::Migrate.new(dir, regex, file, position)
          end
        end
      end
    end
  end
end
