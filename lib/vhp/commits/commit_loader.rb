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

      puts "Traversing CVEs"
      shas = []
      cve_ymls.each do |file|
        yml = load_yml_the_vhp_way(file)
        shas += yml[:fixes].map { |fix| fix[:commit] }
        shas += yml[:vccs].map  { |vcc| vcc[:commit] }
        shas += yml[:interesting_commits][:commits].map { |c| c[:commit] }
      end
      if File.file? 'commits/mega-commits.yml'
        puts "Handling known 'mega' commits"
        megas = load_yml_the_vhp_way('commits/mega-commits.yml') || []
        megas.each do |mega|
          shas.delete mega[:commit]
          @git_api.save_mega(mega[:commit], mega[:note], @clean)
        end
      end

      puts "Getting git logs"
      shas.uniq.reject { |sha| sha.to_s.empty? }.each do |sha|
        begin
          @git_api.save(sha, @clean)
          print '.'
        rescue StandardError => e
          puts "\nFAILED to add #{sha}. #{e}\n"
          failed << sha
        end
      end
      @git_api.save_to_json

      puts "The following commits could not be found:"
      pp failed
    end
  end
end
