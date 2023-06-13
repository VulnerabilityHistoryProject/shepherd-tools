require_relative '../paths'
require_relative '../yml_helper'
require_relative '../parallelism'
require 'open3'

module VHP
  class WeekliesGenerator
    include Paths
    include YMLHelper
    include Parallelism

    @@SECONDS_IN_WEEK = 604800
    @@START_DATE = Time.new(1991, 8, 5).utc # Monday before the birth of WWW

    attr_reader :clean

    def initialize(project, repo, mining, clean)
      @clean = clean
      @mining = mining.strip
      raise "VHP Mining repo not found in #{@mining}" unless File.exist? @mining
      @project = project.strip
      @git_repo = project_source_repo(repo)
      @git_api = GitAPI.new(@mining, @git_repo, @project)

      @project_yml = load_yml_the_vhp_way(project_yml_file(@project))
      @code_ext = @project_yml[:source_code_extensions] || []
      @exclude_filepaths = @project_yml[:exclude_filepaths] || []

      @errors = []
    end

    def run
      puts <<~EOS
        Progress key
          ✅   vulnerability json written
          .   commit looked up
          ⏭️   skipped (already exists)
          🤷   skipped (no offenders)
          ❌   error
      EOS
      ymls = cve_ymls(@project)
      puts initial_report
      parallel_maybe(ymls) do |file|
        cve_yml = load_yml_the_vhp_way(file)
        cve = cve_yml[:CVE]
        if File.exist? weekly_file(cve)
          puts "#{cve}: ⏭️"
        else
          fix_shas = extract_shas_from_commitlist(cve_yml, :fixes)
          offenders = []
          begin
            offenders = @git_api.get_files_from_shas(fix_shas)
          rescue
            @errors << "ERROR #{file}: could not get offender files for #{fix_shas}"
            print '❌'
          end
          offenders = offenders.select {|o| is_code?(o) } # only source code pls
          if offenders.any?
            add(cve, offenders)
            puts "#{cve}: ✅"
          else
            puts "#{cve}: 🤷"
          end
        end
      end
      @errors.each do |err|
        puts "❌: #{err}"
      end
    end

    def initial_report
      yml_count = cve_ymls(@project).size
      json_count = weekly_json_count(@project)
      <<~EOS
        CVE YAML files: #{yml_count}
        JSON weeklies: #{json_count}
        Weeklies to collect: #{yml_count - json_count}
      EOS
    end

    def week_num(timestamp)
      ((timestamp - @@START_DATE) / @@SECONDS_IN_WEEK).to_i
    end

    def nth_week(i)
      (@@START_DATE + (i * @@SECONDS_IN_WEEK).to_i).utc
    end

    def is_code?(filepath)
      return false if @exclude_filepaths.any? do |ex|
        filepath.include? ex
      end
      @code_ext.each do |ext|
        return true if filepath.end_with? ext
      end
      return false
    end

    def write(cve, calendar)
      File.open(weekly_file(cve), 'w+') do |f|
        f.write JSON.fast_generate(calendar)
      end
    end

    def init_weekly(n)
      {
        date: nth_week(n),
        commits: 0,
        insertions: 0,
        deletions: 0,
        files_added: 0,
        files_deleted: 0,
        files_renamed: 0,
        reverts: 0,
        rolls: 0,
        refactors: 0,
        test_files: 0,
        files: [],
        developers: [],
        new_developers: [],
        drive_bys: [],
        ownership_change: false,
      }
    end

    # Append something to an array, then uniq the array
    def append_uniq!(weekly, key, element)
      weekly[key] = (weekly[key] << element).flatten.uniq
    end

    def any_owners_files?(files)
      files.inject(false) do |any_owners, file|
        any_owners || file.to_s.match?(/OWNERS/)
      end
    end

    def revert?(message)
      message.match?(/^Revert "/)
    end

    def roll?(message)
      message.match?(/^Roll /)
    end

    def regression?(message)
      message.downcase.match?(/regression/)
    end

    def refactor?(message)
      message.downcase.match?(/refactor/)
    end

    def any_test_files?(files)
      files.inject(false) do |any_tests, file|
        any_tests || file.match?(/test/)
      end
    end

    def num_name_status(diff, regex)
      diff.name_status.values.select {|s| s.match? regex}.size
    end

    def add(cve, offenders)
      return if offenders.empty?
      calendar = {} # Always start fresh - don't read in the old one
      devs = []
      drive_by_authors = @git_api.get_drive_by_authors()
      git_cmd = <<~CMD
        git -C #{@git_repo} log --author-date-order --reverse --pretty="%H" -- #{offenders.join(' ')}
      CMD
      stdout, stderr, status = Open3.capture3(git_cmd)
      if status != 0
        @errors << "ERROR with git listing commits for CVE #{cve}. Quitting this CVE. Git command: #{git_cmd}. STDERR: #{stderr}"
        return
      end
      commits = stdout.split("\n")
      commits.each do |sha|
        errored = false
        begin
          commit = @git_api.git.object(sha)
          diff = @git_api.git.diff(commit.parent, commit)
          commit_files = diff.stats[:files].keys
          email = commit.author.email
          week_n = week_num(commit.author.date.utc)
          calendar[week_n] ||= init_weekly(week_n)
          weekly = calendar[week_n]
          weekly[:commits]    += 1
          weekly[:insertions] += diff.insertions
          weekly[:deletions]  += diff.deletions
          weekly[:files_added]   += num_name_status(diff, /A/)
          weekly[:files_deleted] += num_name_status(diff, /D/)
          weekly[:files_renamed]  += num_name_status(diff, /R/)
          weekly[:reverts]    += revert?(commit.message) ? 1 : 0
          weekly[:rolls]      += roll?(commit.message) ? 1 : 0
          weekly[:refactors]  += refactor?(commit.message) ? 1 : 0
          weekly[:test_files] += any_owners_files?(commit_files) ? 1 : 0
          weekly[:ownership_change] ||= any_owners_files?(commit_files)
          append_uniq!(weekly, :files, commit_files & offenders)
          append_uniq!(weekly, :developers, email)
          append_uniq!(weekly, :new_developers, [email] - devs)
          append_uniq!(weekly, :drive_bys, email) if drive_by_authors.include?(email)
          devs = (devs << email).flatten.uniq
          print '.'
        rescue => e
          errored = true
          @errors << "ERROR getting Git commit for CVE #{cve}. Skipping this commit. Git error message #{e.message}"
          print '❌'
        end
      end
      write(cve, calendar)
    end

  end

end
