require 'mercenary'
require 'require_all'

module VHP
  class CLI
    def run
      Mercenary.program(:vhp) do |p|
        p.version VHP::VERSION
        p.description 'Tools for managing vulnerability history project data'
        p.syntax 'vhp <subcommand> [options]'
        p.action do # vhp by itself prints the help
          puts p
        end

        p.command(:migrate) do |c|
          c.syntax 'migrate [options]'
          c.description 'Generate a skeleton migration file in ./migrations.'
          c.option 'name', '-n your_migration_name', '--name your_migration_name', 'Specify a name for your file. Optional.'
          c.alias(:migration)
          c.action do |args, options|
            options['name'] ||= 'migration'
            VHP::MigrationGenerator.new.run(options['name'])
          end
        end

        p.command(:validate) do |c|
          c.syntax 'validate <options>'
          c.description 'Validates CVE YAMLs'
          c.option 'cves', '--cves DIR', 'Sets the CVE directory'

          c.action do |args, options|
            VHP::Validator.new(options).validate_ymls
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
              VHP::CurateReady.new(options).print_readiness
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
              VHP::ListCuration.new(options).find_curated
            end
          end

          c.command(:uncurated) do |s|
            s.syntax 'list uncurated <options>'
            s.description 'Lists all uncurated CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'
            s.option 'csv', '--csv DIR', 'Output to a csv file in chosen directory.'

            s.action do |args, options|
              VHP::ListCuration.new(options).find_curated(false)
            end
          end

          c.command(:fixes) do |s|
            s.syntax 'list fixes <options>'
            s.description 'Lists all fixes for CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              VHP::ListFixes.new_CLI(options).print_fixes
            end
          end

          c.command(:nofixes) do |s|
            s.syntax 'list nofixes <options>'
            s.description 'Lists all CVEs that do not have any fix commits'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              VHP::ListFixes.new_CLI(options).print_missing_fixes
            end
          end

          c.command(:vccs) do |s|
            s.syntax 'list vccs <options>'
            s.description 'Lists all VCCs for CVEs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              VHP::ListVCCs.new_CLI(options).print_vccs
            end
          end

          c.command(:novccs) do |s|
            s.syntax 'list novccs <options>'
            s.description 'Lists all CVEs that do not have any VCCs'
            s.option 'cves', '--cves DIR', 'Sets the CVE directory'

            s.action do |args, options|
              VHP::ListVCCs.new_CLI(options).print_missing_vccs
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
              VHP::VulnerableFileExtractor.new(options).extract
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
              VHP::CommitLoader.new(options).add_mentioned_commits
            end
          end
        end

        p.command(:cvss)  do |c|
          c.syntax 'cvss'
          c.description 'Updates all CVEs to conatin CVSS'
          c.option 'cves', '--cves DIR', 'Sets the CVE directory'

          c.action do |args, options|
            VHP::UpdateCVSS.new(options).update_cvss
          end
        end


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
        p.command(:help) do |c|
          c.syntax 'help <options>'
          c.description 'list all the commands with their descriptions'

          c.action do
            puts 'For more information on a specific command, type vhp help command-name'
            puts 'vhp migrate regexp insert_text_file <options>       Migrates YML files.'
            puts 'vhp validate <options>                              Validates CVE YAMLs.'
            puts 'vhp ready subcommand <options>                      Ready commands.'
            puts 'vhp list subcommand <options>                       Lists information in terminal.'
            puts 'vhp find subcommand <options>                       Finds information.'
            puts 'vhp loadcommits subcommand <options>                Finds all mentioned commits in CVE YAMLs and'
            puts '                                                    loads them into the git log.'
            puts 'vhp report timeperiod <options>                     Generates Report.'
          end
          c.command(:migrate) do |s|
            s.action do
              puts 'Migrates YML files'
              puts ''
              puts 'Migration has three arguments and five option and follows the following format:'
              puts 'vhp migrate regexp insert_text_file <options>'
              puts '  regexp                                            The regex for a common line in the files'
              puts '  insert_text_file                                  To insert text into a directory files, you will'
              puts '                                                    need to create a file with the text you wish to'
              puts '                                                    insert. This ARG is the path to this file.'
              puts '<options>'
              puts '  --voff                                            Validation of migrated YAMLs is on by default.'
              puts '                                                    Use this option if not migrating ymls or it'
              puts '                                                    annoys you.'
              puts '  --run                                             The script generated will be automatically run.'
              puts '  --dir DIR                                         This option will set the migration directory.'
              puts '                                                    Default: cves dir'
              puts '  --type TYPE                                       Specifies filename extension. Default: .yml'
              puts ''
              puts 'Examples:'
              puts 'Initial generation of script:'
              puts '  vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt'
              puts 'You can run your generated script like this:'
              puts '  ruby migration/migrate_2019_02_04_12_41.rb'
              puts 'Alternatively, you can generate and run in one command:'
              puts '  vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt --run'
            end
          end
          c.command(:validate) do |s|
            s.action do
              puts 'Validates CVE YAMLs'
              puts ''
              puts 'Validation of YAMLs follows the following format:'
              puts 'vhp validate <options>'
              puts '<options>'
              puts '  --cves DIR                                        Sets the CVE directory. Default: cves'
              puts '  --csv DIR                                         Output to a csv file. Default Dir: csvs'
              puts ''
              puts 'Examples:'
              puts '  vhp validate'
              puts '  vhp validate --cves ../mydir/cves'
            end
          end
          c.command(:ready) do |s|
            s.action do
              puts 'Ready commands'
              puts ''
              puts 'The ready command follows the following format:'
              puts 'vhp ready subcommand <options>'
              puts 'subcommand'
              puts '  curated                                           Finds all YAMLs ready to be curated'
              puts '<options>'
              puts '  --cves DIR                                        Sets the CVE directory. Default: cves'
              puts '  --unready                                         Find unready YAMLs to be curated'
            end
          end
          c.command(:list) do |s|
            s.action do
              puts 'Lists information in terminal'
              puts ''
              puts 'The list command follows the following format:'
              puts 'vhp list subcommand <options>'
              puts 'subcommand'
              puts '  curated                                           Lists all curated cves'
              puts '  uncurated                                         Lists all uncurated cves'
              puts '  fixes                                             Lists all fix shas'
              puts '<options>'
              puts '  --cves DIR                                        Sets the CVE directory. Default: cves'
              puts '  --csv DIR                                         Output to a csv file. Default Dir: csvs'
              puts ''
              puts 'Examples:'
              puts '  vhp list curated'
              puts '  vhp list uncurated --cves ../cves'
              puts '  vhp list fixes'
            end
          end
          c.command(:find) do |s|
            s.action do
              puts 'Finds information'
              puts ''
              puts 'The find command follows the following format:'
              puts 'vhp find subcommand <options>'
              puts 'subcommand'
              puts '  publicvulns                                       Find all vulnerable files from the gitlog'
              puts '<options>'
              puts '  --repo DIR                                        Sets the repository directory. Default: current'
              puts '                                                    working directory'
              puts '  --cves DIR                                        Sets the CVE directory. Default: cves'
              puts '  --period PERIOD                                   Sets a default time period for the test. Either'
              puts '                                                    "6_month" or "all_time"'
              puts '  --start DATE                                      Sets the start date of the period. Cannot be'
              puts '                                                    used with --period'
              puts '  --end DATE                                        Sets the end date of the period. Cannot be used'
              puts '                                                    with --period'
              puts '  --output DIR                                      Sets the directory where the CSV will be saved.'
              puts '  --period_name NAME                                Sets the name of the period. E.g. "12_months",'
              puts '                                                    "2_years"'
              puts ''
              puts 'Examples:'
              puts '  vhp find curated'
              puts '  vhp find uncurated --dir ../mydir'
              puts '  vhp find publicvulns --repo struts --period 6_month'
              puts '  vhp find publicvulns --repo tomcat'
            end
          end
          c.command(:loadcommits) do |s|
            s.action do
              puts 'Finds all mentioned commits in CVE YAMLs and loads them into the git log'
              puts ''
              puts 'Loading the git log JSON with commit data follows the following format:'
              puts 'vhp loadcommits subcommand <options>'
              puts 'subcommand'
              puts '  mentioned                                         All commits mentioned in a CVE YAML'
              puts '<options>'
              puts '  --json JSON                                       Sets the gitlog_json location. Default:'
              puts '                                                    commits/gitlog.json'
              puts '  --repo DIR                                        Sets the repository directory. Default: current'
              puts '                                                    working directory'
              puts '  --cves DIR                                        Sets the CVE directory. Default: cves'
              puts '  --skip_existing                                   Skips shas that are already in the JSON'
              puts ''
              puts 'Examples:'
              puts '  vhp loadcommits mentioned --repo struts'
              puts '  vhp loadcommits mentioned --json ../../data/commits/gitlog.json --skip_existing'
            end
          end
          c.command(:report) do |s|
            s.action do
              puts 'Generating reports follows the following format'
              puts 'vhp report timeperiod <options>'
              puts 'timeperiod'
              puts '  weekly                                            Time period of one week'
              puts '<options>'
              puts '  --save DIR                                        By default, reports are saved in commits/weeklies.'
              puts '                                                    Manually set the directory with this option.'
              puts '  --repo DIR                                        By default, the working directory is assumed to'
              puts '                                                    be the repo directory. Manually set the directory'
              puts '                                                    with this option.'
              puts '  --cve DIR                                         By default, the cve directory is assumed to be'
              puts '                                                    "/cves". Manually set the directory with this'
              puts '                                                    option.'
              puts 'Examples:'
              puts '  vhp report weekly --save reports, --repo ../src'
            end
          end
        end
      end
    end
  end
end
