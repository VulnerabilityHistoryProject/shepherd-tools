require 'git'
require 'json'
require 'fileutils'
require_relative 'git_api'
require_relative '../utils/helper'
require_relative '../paths'
require_relative '../yml_helper'

module VHP
  class CommitLoader
    include Paths
    include YMLHelper
    using VHP::StringRefinements

    def initialize(project, repo, mining, clean)
      @clean = clean
      @mining = mining.strip
      raise "VHP Mining repo not found in #{@mining}" unless File.exist? @mining
      @project = project.strip
      @git_api = GitAPI.new(@mining, project_source_repo(repo), @project)
    end

    def add_mentioned_commits
      failed = []
      successes = 0
      shas = []
      potential_megas = []
      mega_commits = load_mega_commits
      cve_ymls(@project).each do |file|
        yml = load_yml_the_vhp_way(file)
        shas += yml[:fixes].map { |fix| fix[:commit] }
        shas += yml[:vccs].map  { |vcc| vcc[:commit] }
        shas += yml[:interesting_commits][:commits].map { |c| c[:commit] }
      end
      shas = shas.uniq.reject { |sha| sha.to_s.empty? }
      puts "INFO: Found #{shas.size} mentioned commits in #{@project} ymls."
      print "INFO: Looking up commits"
      mega_commits.each do |mega|
        if shas.include? mega[:commit]
          @git_api.save_mega(mega[:commit], mega[:note], @clean)
          shas.delete mega[:commit]
        end
      end

      shas.each do |sha|
        begin
          @git_api.save(sha, @clean)
          print '.'
          successes += 1
        rescue StandardError => e
          puts "\nFAILED to add #{sha}. #{e}\n"
          failed << sha
        end
      end
      @git_api.warn_megas
      @git_api.save_to_json
      puts "INFO: Successfully saved #{successes} commits."
      puts "INFO: Total commits in vhp-mining/gitlogs/#{@project}.json now: #{@git_api.gitlog_size}"
      unless failed.empty?
        puts "WARNING! The following commits could not be found: "
        pp failed
      end
    end

    def load_mega_commits
      load_yml_the_vhp_way("projects/#{@project}.yml")[:mega_commits]
    end
  end
end
