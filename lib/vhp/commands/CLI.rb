require 'mercenary'
require_relative '../migrate/migrate_gen'
require_relative '../validate/validator'
require_relative'../version'

module ShepherdTools
  class CLI

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
        p.command(:validate) do |c|
          c.syntax "validate"
          c.description "Validates CVE YAMLs"

          c.action do |args, options|
            ShepherdTools::Validator.new.validate_ymls
          end
        end
      end
    end
  end
end
