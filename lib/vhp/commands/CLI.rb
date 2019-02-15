require 'mercenary'
require_relative '../migrate/migrate_gen'
require_relative '../validate/validator'
require_relative '../version'
require_relative '../find/finder'
require_relative '../report/report_gen'

module ShepherdTools
  class CLI
    def run
      Mercenary.program(:vhp) do |p|
        p.version ShepherdTools::VERSION
        p.description description = 'Tools for the vulnerability history project'
        p.syntax 'vhp <subcommand> [options]'

        p.command(:migrate) do |c|
          c.syntax 'migrate <ARGS> [options]'
          c.description 'Migrates CVE YAMLs'
          c.option 'voff', '--voff', 'Turns off validation as you migrate'
          c.option 'run', '--run', 'Runs the migration script you generated'
          c.option 'dir', '--dir DIR', 'Sets the dir for the files to be migrated'
          c.option 'filetype', '--type TYPE', 'The extension of the files to be migrated'
          c.option 'regex_end', '--end REGEX',
           'Only use if replacing text. All text before this regex (After and including the first regex) will be replaced.'

          c.action do |args, options|
            ShepherdTools::MigrateGenerator.new.gen(args, options)
          end
        end

        p.command(:validate) do |c|
          c.syntax 'validate <options>'
          c.description 'Validates CVE YAMLs'
          c.option 'dir', '--dir DIR', 'Sets the CVE directory'

          c.action do |args, options|
            ShepherdTools::Validator.new(options).validate_ymls
          end
        end

        p.command(:find) do |c|
          c.syntax 'find subcommand <options>'
          c.description 'Finds information about CVEs'

          c.command(:curated) do |s|
            s.syntax 'find curated <options>'
            s.description 'Finds all curated CVEs'
            s.option 'dir', '--dir DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::Finder.new(options).find_curated
            end
          end

          c.command(:uncurated) do |s|
            s.syntax 'find uncurated <options>'
            s.description 'Finds all uncurated CVEs'
            s.option 'dir', '--dir DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::Finder.new(options).find_curated(false)
            end
          end
        end
        =begin
        p.command(:report) do |c|
          c.syntax 'report timeperiod'
          c.description 'Generates a report'

          c.command(:weekly) do |s|
            s.syntax 'report weekly <options>'
            s.description 'Generates a commit report by week'
            s.option 'save', '--save DIR', 'Sets the directory where the reports are saved'
            s.option 'repo', '--repo DIR', 'Sets the repo directory'
            s.option 'cves', '--cve Dir', 'Sets the cve directory'
            #s.option 'skip_existing', '--skip_existing', 'Skips '

            s.action do |args, options|
              Report::ReportGenerator.new.gen_weekly(options)
            end
          end
        end
        =end
      end
    end
  end
end
