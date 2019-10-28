require 'mercenary'
require_relative '../migrate/migrate_gen'
require_relative '../validate/validator'
require_relative '../version'
require_relative '../cve_info/list_curation'
require_relative '../cve_info/list_fixes'
require_relative '../cve_info/list_vccs'
require_relative '../report/report_gen'
require_relative '../commits/load_commits'
require_relative '../commits/vuln_files'
require_relative '../ready/curate_ready'
require_relative '../cvss/update_cvss.rb'

module ShepherdTools
  class CLI
    def run
      Mercenary.program(:vhp) do |p|
        p.version ShepherdTools::VERSION
        p.description description = 'Tools for the vulnerability history project'
        p.syntax 'vhp <subcommand> [options]'

        p.command(:migrate) do |c|
          c.syntax 'migrate <ARGS> [options]'
          c.description 'Migrates files'
          c.option 'voff', '--voff', 'Turns off validation as you migrate'
          c.option 'run', '--run', 'Runs the migration script you generated'
          c.option 'dir', '--dir DIR', 'Sets the dir for the files to be migrated'
          c.option 'filetype', '--type TYPE', 'The extension of the files to be migrated'

          c.action do |args, options|
            ShepherdTools::MigrateGenerator.new.gen(args, options)
          end
        end

        p.command(:validate) do |c|
          c.syntax 'validate <options>'
          c.description 'Validates CVE YAMLs'
          c.option 'cves', '--cves DIR', 'Sets the CVE directory'

          c.action do |args, options|
            ShepherdTools::Validator.new(options).validate_ymls
          end
        end

        p.command(:ready) do |c|
          c.syntax 'ready subcommand'
          c.description 'Ready commands'

          c.command(:curated) do |s|
            c.syntax 'ready curated'
            c.description 'Ready curated'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'
            s.option 'unready', '--unready', 'Find unready CVE YAMLs'
            s.option 'csv', '--csv DIR', 'Output to a csv file in chosen directory.'

            s.action do |args, options|
              ShepherdTools::CurateReady.new(options).print_readiness
            end
          end
        end

        p.command(:list) do |c|
          c.syntax 'list subcommand <options>'
          c.description 'Lists information in terminal'

          c.command(:curated) do |s|
            s.syntax 'list curated <options>'
            s.description 'Lists all curated CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'
            s.option 'csv', '--csv DIR', 'Output to a csv file in chosen directory.'

            s.action do |args, options|
              ShepherdTools::ListCuration.new(options).find_curated
            end
          end

          c.command(:uncurated) do |s|
            s.syntax 'list uncurated <options>'
            s.description 'Lists all uncurated CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'
            s.option 'csv', '--csv DIR', 'Output to a csv file in chosen directory.'

            s.action do |args, options|
              ShepherdTools::ListCuration.new(options).find_curated(false)
            end
          end

          c.command(:fixes) do |s|
            s.syntax 'list fixes <options>'
            s.description 'Lists all fixes for CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::ListFixes.new_CLI(options).print_fixes
            end
          end

          c.command(:nofixes) do |s|
            s.syntax 'list nofixes <options>'
            s.description 'Lists all CVEs that do not have any fix commits'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::ListFixes.new_CLI(options).print_missing_fixes
            end
          end

          c.command(:vccs) do |s|
            s.syntax 'list vccs <options>'
            s.description 'Lists all VCCs for CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::ListVCCs.new_CLI(options).print_vccs
            end
          end

          c.command(:novccs) do |s|
            s.syntax 'list novccs <options>'
            s.description 'Lists all CVEs that do not have any VCCs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              ShepherdTools::ListVCCs.new_CLI(options).print_missing_vccs
            end
          end
        end

        p.command(:find) do |c|
          c.syntax 'find subcommand <options>'
          c.description 'Finds information'

          c.command(:publicvulns) do |s|
            s.syntax 'find publicvulns <options>'
            s.description 'Finds all files with vulnerabilities'
            s.option 'cves', '--cves Dir', 'Sets the CVE directory'
            s.option 'repo', '--repo DIR', 'Sets the repository directory'
            s.option 'period', '--period PERIOD', 'Sets the time period'
            s.option 'start', '--start DATE', 'Sets the starting date'
            s.option 'end', '--end DATE', 'Sets the end date'
            s.option 'output', '--output DIR', 'Sets the dir where output will be saved'
            s.option 'period_name', '--period_name NAME', 'Sets the name of the time period'

            s.action do |args, options|
              ShepherdTools::VulnerableFileExtractor.new(options).extract
            end
          end
        end

        p.command(:loadcommits) do |c|
          c.syntax 'loadcommits subcommand <options>'
          c.description 'Finds all mentioned commits in CVE YAMLs and loads them into the git log'

          c.command(:mentioned) do |s|
            s.syntax 'loadcommits mentioned'
            s.option 'gitlog_json', '--json JSON', 'Sets the location of gitlog.json'
            s.option 'repo', '--repo DIR', 'Sets the repository directory'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'
            s.option 'skip_existing', '--skip_existing', 'Skips shas that already exist in the gitlog.json'

            s.action do |args, options|
              ShepherdTools::CommitLoader.new(options).add_mentioned_commits
            end
          end
        end

        p.command(:cvss)  do |c|
          c.syntax 'cvss'
          c.description 'Updates all CVEs to conatin CVSS'
          c.option 'cves', '--cves DIR', 'Sets the CVE directory'

          c.action do |args, options|
            ShepherdTools::UpdateCVSS.new(options).update_cvss
          end
        end

        p.command(:help) do |c|
          c.syntax 'help <options>'
          c.description 'list all the commands with their descriptions'

          c.action do
            puts 'For more information on a specific command, type vhp help command-name'
            puts 'vhp migrate regexp insert_text_file <options>       Migrates files.'
            puts 'vhp validate <options>                              Validates CVE YAMLs.'
            puts 'vhp ready subcommand <options>                      Ready commands.'
            puts 'vhp list subcommand <options>                       Lists information in terminal.'
            puts 'vhp find subcommand <options>                       Finds information.'
            puts 'vhp loadcommits subcommand <options>                Finds all mentioned commits in CVE YAMLs and loads'
            puts '                                                    them into the git log.'
            puts 'vhp report timeperiod <options>                     Generates Report.'
          end
          c.command(:migrate) do |s|
            s.action do
              puts 'Migrates files'
              puts ''
              puts 'Migration has three arguments and five option and follows the following format:'
              puts 'vhp migrate regexp insert_text_file <options>'
              puts ''
              puts '  regexp                                              The regex for a common line in the files'
              puts '  insert_text_file                                    To insert text into a directory files, you will'
              puts '                                                      need to create a file with the text you wish to'
              puts '                                                      insert. This ARG is the path to this file.'
              puts '  --voff                                              Validation of migrated Yamls is on by default.'
              puts '                                                      Use this option if not migrating ymls or it'
              puts '                                                      annoys you.'
              puts '  --run                                               The script generated will be automatically run.'
              puts '  --dir DIR                                           This option will set the migration directory.'
              puts '                                                      Default: cves dir'
              puts '  --type TYPE                                         Specifies filename extension. Default: .yml'
              puts ''
              puts 'Examples:'
              puts ''
              puts 'Initial generation of script:'
              puts 'vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt'
              puts ''
              puts 'You can run your generated script like this:'
              puts 'ruby migration/migrate_2019_02_04_12_41.rb'
              puts ''
              puts 'Alternatively, you can generate and run in one command:'
              puts 'vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt --run'
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
