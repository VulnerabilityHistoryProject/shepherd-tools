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
      @git_api = GitAPI.new(project_source_repo(cli_options[:repo]))
    end

    def add_mentioned_commits
      failed = []
      successes = 0
      shas = []

      cve_ymls.each do |file|
        yml = load_yml_the_vhp_way(file)
        shas += yml[:fixes].map { |fix| fix[:commit] }
        shas += yml[:vccs].map  { |vcc| vcc[:commit] }
        shas += yml[:interesting_commits][:commits].map { |c| c[:commit] }
      end
      shas = shas.uniq.reject { |sha| sha.to_s.empty? }
      puts "INFO: Found #{shas.size} mentioned commits in CVE ymls."
      print "INFO: Looking up commits"
      if File.file? 'commits/mega-commits.yml'
        megas = load_yml_the_vhp_way('commits/mega-commits.yml') || []
        megas.each do |mega|
          if shas.include? mega[:commit]
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
end
