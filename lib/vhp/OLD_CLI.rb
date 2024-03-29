require 'mercenary'
require_relative 'string_refinements'

module VHP
  class OLDCLI
    using StringRefinements

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
          c.option 'name', '-n your_migration_name',
                   '--name your_migration_name',
                   'Specify a name for your file. Optional.'
          c.alias(:migration)
          c.action do |args, options|
            options['name'] ||= 'migration'
            VHP::MigrationGenerator.new.run(options['name'])
          end
        end


        p.command(:list) do |c|
          c.syntax 'list <subcommand> <options>'
          c.description 'Lists information in terminal'

          c.command(:ready) do |s|
            s.syntax 'list ready <options>'
            s.description 'List the curation readiness of the CVEs for a project.'
            c.option :project, '--project PROJECT', 'Shortname (subdomain) of the project to lookup'
            c.option :min_fixes, '--min-fixes NUM', 'Min number of fixes to show'
            c.option :min_fixes, '--min-vccs NUM',  'Min number of vccs to show'
            c.option :max_level, '--max-level NUM', 'Maximum curation level'
            c.option :full, '--full',               'Print out Fixes and VCCs'
            s.action do |_args, options|
              VHP::CurateReady.new(options).print_readiness
            end
          end

          c.command(:curated) do |s|
            s.syntax 'list curated <options>'
            s.description 'Lists all curated CVEs'
            s.option 'csv', '--csv FILE', 'Output to a csv file'
            s.action do |args, options|
              VHP::ListCuration.new(options).find_curated
            end
          end

          c.command(:uncurated) do |s|
            s.syntax 'list uncurated <options>'
            s.description 'Lists all uncurated CVEs'
            s.option 'csv', '--csv FILE', 'Output to a csv file'
            s.action do |args, options|
              VHP::ListCuration.new(options).find_curated(false)
            end
          end

          c.command(:fixes) do |s|
            s.syntax 'list fixes <options>'
            s.description 'Lists all fix commits for CVEs'
            s.option 'cves', '--cves FILE', 'Sets the CVE directory'
            s.action do |args, options|
              VHP::ListFixes.new_CLI(options).print_fixes
            end
          end

          c.command(:nofixes) do |s|
            s.syntax 'list nofixes'
            s.description 'Lists all CVEs that do not have any fix commits'
            s.action do |args, options|
              VHP::ListFixes.new_CLI(options).print_missing_fixes
            end
          end

          c.command(:vccs) do |s|
            s.syntax 'list vccs'
            s.description 'Lists all VCCs for CVEs'
            s.action do |args, options|
              VHP::ListVCCs.new_CLI(options).print_vccs
            end
          end

          c.command(:novccs) do |s|
            s.syntax 'list novccs'
            s.description 'Lists all CVEs that do not have any VCCs'
            s.action do |args, options|
              VHP::ListVCCs.new_CLI(options).print_missing_vccs
            end
          end

          c.command(:subsystems) do |s|
            s.syntax 'subsystems'
            s.description 'List all subsystems'
            s.action do |_args, _options|
              VHP::ListSubsystems.new.run
            end
          end
        end # list

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
          c.syntax 'loadcommits <options>'
          c.description 'Save mentioned commits in CVE ymls to vhp-mining/commits/gitlog.json'
          c.option :mining,  '--mining DIR', 'Sets the VHP mining repo'
          c.option :repo,    '--repo DIR', 'Sets the repository directory'
          c.option :project, '--project PROJECT', 'Shortname (subdomain) of the project to lookup'
          c.option :clean,   '--clean', 'Skips shas that already exist in the gitlog json'
          c.action do |args, options|
            VHP::CommitLoader.new(options).add_mentioned_commits
          end
        end

        p.command(:nvd)  do |c|
          c.syntax 'nvd'
          c.description 'Updates the project CVEs to get CVSS, announced, and fix data from NVD.'
          c.option :apikey,   '--api KEYFILE',     'Use the NVD API (THROTTLED!)'
          c.option :nvd_repo,  '--nvd-repo DIR',    'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)'
          c.option :project,  '--project PROJECT', 'Shortname (subdomain) of the project to lookup'
          c.option :cve,  '--cve CVE-YYYY-NNNNN', 'If specified, only update the one CVE. Otherwise, do the whole project'
          c.action do |_args, options|
            VHP::NVDLoader.new(options).run
          end
        end

        p.command(:nofixes)  do |c|
          c.syntax 'cvss'
          c.description 'Lists all CVEs that have no fix commits listed.'
          c.action do |args, options|
            VHP::ListNoFixes.new.run
          end
        end

        p.command(:weeklies) do |c|
          c.syntax 'weeklies <options>'
          c.description 'Collects weekly reports. See `vhp help weeklies`.'
          c.option :repo,    '--repo DIR', 'Sets the repo directory'
          c.option :mining,  '--mining DIR', 'Sets the VHP mining repo'
          c.option :project, '--project PROJECT', 'Shortname (subdomain) of the project to lookup'
          c.option :clean,   '--clean', "Don't skip CVEs already saved. SLOW!"
          c.action do |args, options|
            WeekliesGenerator.new(options).run
            puts "Done!"
          end
        end

        p.command(:corpus) do |c|
          c.syntax 'corpus [fixes]'
          c.description 'Generate a corpus of data for a specific type of project.'
          c.command(:fixes) do |f|
            f.description 'Generate a collection of source code files of before-and-after fixes to vulnerabilities'
            f.option :repo, '--repo DIR', 'Sets the repository directory'
            f.option :clean, '--clean', 'Rebuild directory completely'
            f.alias :fix
            f.action do |args, options|
              VHP::FixCorpus.new(options).run
            end
          end
        end

        p.command(:fixcrawl) do |c|
          c.syntax 'fixcrawl [CVE]'
          c.description 'Web crawl URLs CVE information in NVD to find potential git commits as fixes'
          c.option :repo, '--repo DIR', 'Sets the repository directory'
          c.action do |args, options|
            VHP::FixCrawl.new(args, options).run
          end
        end

        p.command(:update) do |c|
          c.syntax 'update [project]'
          c.description 'Check for an retrieve new CVEs for the given project'
          c.option :dry_run, '--dry-run',   'Lists new CVEs without loading them'
          c.option :skip_nvd, '--skip-nvd', "Don't look up information from the NVD"
          c.option :nvd_repo,  '--nvd-repo DIR',    'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)'
          c.action do |args, options|
            VHP::Update.new(args, options).run
          end
        end

        p.command(:new) do |c|
          c.syntax 'new CVE-YYYY-NNNNN [OPTIONS]'
          c.description 'Create a new CVE file, optionally looking up NVD info'
          c.option :project,   '--project PROJECT', 'Shortname (subdomain) of the project to add to'
          c.option :skip_nvd,  '--skip-nvd', "Don't look up information from the NVD"
          c.option :force,     '--force', "Overwrite the file if it exists"
          c.option :nvd_repo,  '--nvd-repo DIR',    'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)'
          # c.option :apikey,  '--apikey FILE', 'File to the NVD API key, for faster loading'
          c.action do |args, options|
            raise 'Project needed' unless options.key? :project
            project = options[:project]
            cve = args[0].strip
            skip_nvd = options[:skip_nvd]
            nvd_repo = options[:nvd_repo]
            VHP::NewCVE.new(project, cve, skip_nvd, nvd_repo).run
          end
        end

        p.command(:help) do |c|
          c.syntax 'help <options>'
          c.description 'Provide details on all subcommands'
          c.action do
            puts <<~EOS

            DESCRIPTION

              Documentation for every command.

            SYNTAX

              vhp help
              vhp help <command>

            COMMANDS

              new                            Create a new CVE yml, NVD lookup
              corpus                         Generate corpus of fix patches
              migrate                        Generate migration file for CVE ymls
              list <subcommand> <options>    List various CVEs, e.g. fixed, vcc
              find <subcommand> <options>    Finds information.
              weeklies <options>             Generates weeklies reports.
              loadcommits <options>          Gets Git info for all mentioned
                                             commits in CVE YAMLs, puts in
                                             gitlog.json
              nofixes                        List CVEs without fixe commits
              fixcrawl                       Crawl NVD urls for fix commits
              nvd                            Load CVSS, dates from NVD

            EXAMPLES

              vhp help list
              vhp help weeklies
            EOS
          end

          c.command(:migrate) do |s|
            s.alias 'migration'
            s.action do
              puts <<~EOS

                DESCRIPTION

                  Generates a skeleton migration file in migrations/ dir.
                  Named after the current datetime and your own name.
                  Alias: migration

                OPTIONS

                  --name  Your name to go in the file. No spaces please.

                EXAMPLES

                  vhp migrate foo_bar
                  vhp migration foo_bar

              EOS
            end
          end

          c.command(:list) do |s|
            s.action do
              puts <<-EOS.strip_heredoc

              DESCRIPTION

                Make a list of CVEs or other data based on common queries.

              SYNTAX

                vhp list <subcommand> <options>

              SUBCOMMANDS

                ready             Lists all CVEs not curated to skeleton level
                curated           List all curated cves
                uncurated         List all uncurated cves
                fixes             List all fix shas

              OPTIONS

                --csv FILE        Output to a csv file

              EXAMPLES

                vhp list ready --project kernel
                vhp list ready --project tomcat --min-fixes 1 --min-vccs 1 --max-level 0.9
                vhp list fixes
              EOS
            end
          end

          c.command(:find) do |s|
            s.action do
              puts <<-EOS.strip_heredoc

              DESCRIPTION

                Finds information

              SYNTAX

              vhp find subcommand <options>
              subcommand
                publicvulns          Find all vulnerable files from the gitlog
              <options>
                --repo DIR           Sets the repository directory. Default: current
                                     working directory
                --cves DIR           Sets the CVE directory. Default: cves
                --period PERIOD      Sets a default time period for the test. Either
                                     "6_month" or "all_time"
                --start DATE         Sets the start date of the period. Cannot be
                                     used with --period
                --end DATE           Sets the end date of the period. Cannot be used
                                     with --period
                --output DIR         Sets the directory where the CSV will be saved.
                --period_name NAME   Sets the name of the period. E.g. "12_months",
                                     "2_years"

              Examples:
                vhp find curated
                vhp find uncurated --dir ../mydir
                vhp find publicvulns --repo struts --period 6_month
                vhp find publicvulns --repo tomcat
              EOS
            end
          end

          c.command(:loadcommits) do |s|
            s.action do
              puts <<-EOS.strip_heredoc

              DESCRIPTION

                Finds all mentioned commits in CVE YAMLs saves them to the
                commit database in commits/gitlog.json.

              SYNTAX

                vhp loadcommits <options>

              OPTIONS

                --repo DIR     The repository to get from the gitlog.
                               Default: ./tmp/src/
                --clean        Don't skip shas already saved. SLOW!

              EXAMPLES
                vhp loadcommits mentioned --repo ../struts-src
              EOS
            end
          end

          c.command(:weeklies) do |s|
            s.action do
              puts <<~EOS

              DESCRIPTION

                Collect various metrics for every active week on the timeline
                of a vulnerability.

                Saves to vhp-mining/weeklies/<project>/CVE-*.json

              SYNTAX

                vhp weeklies [OPTIONS]

              OPTIONS

                --repo DIR        The source repository to get from the gitlog.
                --mining DIR      The VHP mining repo'
                --clean           Don't skip CVEs already saved. SLOW!
                --project PROJECT Shortname (subdomain) of the project to analyze (e.g. tomcat)

              EXAMPLES

                vhp weeklies --repo ../tomcat --mining ../vhp-mining --project tomcat

              EOS
            end
          end

        end

      end # Mercenary.program
    end # run
  end # class
end # module
