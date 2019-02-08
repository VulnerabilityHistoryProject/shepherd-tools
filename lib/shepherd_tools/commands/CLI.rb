require 'mercenary'
require_relative '../migrate/migrate_gen.rb'
require_relative'../version.rb'

module ShepherdTools
  class CLI

    def run()
      Mercenary.program(:shepherd_tools) do |p|
        p.version ShepherdTools::VERSION
        p.description description = "Tools for the vulnerability history project"
        p.syntax 'shepherd_tools <subcommand> [options]'

        p.command(:new) do |c|
          c.syntax "new PATH"
          c.description "Creates a new Shepherd-Tools scaffold in PATH"
        end

        p.command(:migrate) do |c|
          c.syntax "migrate <ARGS> [options]"
          c.description "Migrates CVE YAMLs"
          c.option "validate", "--validate", "Validates YAMLs as you migrate"
          c.option "run", "--run", "Runs the migration script you generated"

          c.action do |args, options|
            validate = options.key? 'validate'
            run = options.key? 'run'
            ShepherdTools::MigrateGenerator.new.gen(args, validate, run)
          end
        end
      end
    end
  end
end
