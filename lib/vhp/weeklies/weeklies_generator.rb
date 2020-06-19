require_relative '../paths'
require_relative '../yml_helper'
require_relative '../parallelism'

module VHP
  class WeekliesGenerator
    include Paths
    include YMLHelper
    include Parallelism
    @@SECONDS_IN_WEEK = 604800
    @@START_DATE = Time.new(1991, 8, 5).utc # Monday before the birth of WWW

    attr_reader :clean

    def initialize(cli_options)
      @clean = cli_options.key? :clean
      @git_repo = project_source_repo(cli_options[:repo])
      @git_api = GitAPI.new(@git_repo)
    end

    def run
      puts <<~EOS
        Progress key
          v    vulnerability json written
          .    commit looked up 
      EOS
      parallel_maybe(cve_ymls, progress: 'Generating Weeklies') do |file|
        cve_yml = load_yml_the_vhp_way(file)
        fix_shas = extract_shas_from_commitlist(cve_yml, :fixes)
        offenders = []
        begin
          offenders = @git_api.get_files_from_shas(fix_shas)
        rescue
          puts "ERROR #{file}: could not get files for #{fix_shas}"
        end
        add(cve_yml[:CVE], offenders)
      end
    end

    def week_num(timestamp)
      ((timestamp - @@START_DATE) / @@SECONDS_IN_WEEK).to_i
    end

    def nth_week(i)
      (@@START_DATE + (i * @@SECONDS_IN_WEEK).to_i).utc
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
      begin
        commits = `git -C #{@git_repo} log --author-date-order --reverse --pretty="%H" -- #{offenders.join(' ')}`.split("\n")
      rescue => e
        warn "ERROR with git listing commits for CVE #{cve}. Quitting this CVE."
        warn "ERROR git error message for above problem: #{e.message}"
        return
      end
      commits.each do |sha|
        errored = false
        begin
          commit = @git_api.git.object(sha)
          diff = @git_api.git.diff(commit.parent, commit)
          print '.'
        rescue => e
          errord = true
          warn "ERROR getting Git commit for CVE #{cve}. Skipping this commit."
          warn "ERROR git error message for above problem. #{e.message}"
        end
        unless errored
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
        end
      end
      write(cve, calendar)
    end

  end

end
