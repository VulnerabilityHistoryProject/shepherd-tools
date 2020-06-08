require 'git'
require 'json'
require 'logger'
require 'parallel'
require_relative 'weekly_report'
require_relative '../utils/git'
module VHP
  class ReportGenerator
    def gen_weekly(input_options)
      options = {}
      options[:save_dir] = save_dir(input_options)
      options[:repo] = repo(input_options)
      options[:cves] = cves(input_options)
      #options[:skip_existing] = skip_existing(input_options)

      puts "Generating a report with options: #{options}"
      git_utils = VHP::GitLog.new(options[:repo])
      puts 'here1'
      weekly_report = VHP::WeeklyReport.new(options)
      puts 'here2'
      yml_path = options[:cves] + '/**/*.yml'
      ymls = Dir[yml_path].to_a
      prog_string = 'Generating Weeklies'
      Parallel.each(ymls, in_processes: 8, progress: prog_string) do |file|
        warn 'WARNING!! We ripped out activesupport and need to do our own deep_symobolize keys'
        yml = YAML.load(File.open(file)).deep_symbolize_keys
        fix_commits = yml[:fixes].inject([]) do |memo, fix|
          unless fix[:commit].blank?
            memo << fix[:commit]
          end
        end
        begin
          offenders = git_utils.get_files_from_hash(fix_commits)
        rescue
          puts "ERROR #{file}: could not get files for #{fix_commits}"
        end
        weekly_report.add(yml[:CVE], offenders)
      end


    end

    def save_dir(options)
      dir = 'commits/weeklies'
      if options.key? 'save'
        dir = options['save']
      end
      dir
    end

    def repo(options)
      repo = Dir.pwd
      if options.key? 'repo'
        repo = options['repo']
      end
      repo
    end

    def cves(options)
      cves = 'cves'
      if options.key? 'cves'
        cves = options['cves']
      end
      cves
    end

    def skip_existing(options)
      skip_existing = false
      if options.key? 'skip_existing'
        skip_existing = true
      end
      skip_existing
    end

  end
end
