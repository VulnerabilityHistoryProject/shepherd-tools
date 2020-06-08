require 'git'
require 'json'
require 'fileutils'
require_relative '../utils/git'
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
      @repo = project_source_repo(cli_options[:repo])
    end

    def add_mentioned_commits
      puts <<-EOS.strip_heredoc
        Adding mentioned commit with these options:
          clean: #{@clean}
          repo: #{@repo}
      EOS

      saver = GitSaver.new(@repo, gitlog_json)
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
          saver.add_mega(mega[:commit], mega[:note], @clean)
        end
      end

      puts "Getting git logs"
      shas.uniq.reject { |sha| sha.to_s.empty? }.each do |sha|
        begin
          saver.add(sha, @clean)
          print '.'
        rescue StandardError => e
          puts "\nFAILED to add #{sha}. #{e}\n"
          failed << sha
        end
      end
      saver.save

      puts "The following commits could not be found:"
      pp failed
    end
  end
end
