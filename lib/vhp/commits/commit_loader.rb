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

    def initialize(cli_options)
      @clean = cli_options.key? :clean
      @mining = cli_options[:mining] || './tmp/vhp-mining'
      raise "VHP Mining repo not found in #{@mining}" unless File.exist? @mining
      # @git_api = GitAPI.new(project_source_repo(cli_options[:repo]))
    end

    def add_mentioned_commits
      failed = []
      successes = 0
      shas = []
      mega_commits = load_mega_commits

      projects.each do |project|
        cve_ymls(project).each do |file|
          yml = load_yml_the_vhp_way(file)
          shas += yml[:fixes].map { |fix| fix[:commit] }
          shas += yml[:vccs].map  { |vcc| vcc[:commit] }
          shas += yml[:interesting_commits][:commits].map { |c| c[:commit] }
        end
        shas = shas.uniq.reject { |sha| sha.to_s.empty? }
        puts "INFO: Found #{shas.size} mentioned commits in #{project} ymls."
        print "INFO: Looking up commits"

        shas.reject! {|sha| mega_commits[project].include? sha }
        mega_commits[project].each do |mega_commit|
          if shas.include? mega_commit

          end
        end

              shas.delete mega[:commit]
              @git_api.save_mega(mega[:commit], mega[:note], @clean)
            end
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
        puts ""
        @git_api.save_to_json
        puts "INFO: Successfully saved #{successes} commits."
        puts "INFO: Total commits in gitlog.json now: #{@git_api.gitlog_size}"
        unless failed.empty?
          puts "WARNING! The following commits could not be found: "
          pp failed
        end
      end

    end

    def load_mega_commits
      mega_commits = {}
      Dir["projects/*.yml"].each do |f|
        yml = load_yml_the_vhp_way(f)
        project = yml[:subdomain]
        mega_commits[project] = yml[:mega_commits].map {|c| c[:commit] }
      end
      return mega_commits
    end
  end
end
