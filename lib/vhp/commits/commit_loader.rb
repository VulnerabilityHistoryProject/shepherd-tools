require 'git'
require 'json'
require 'yaml'
require 'fileutils'
require_relative '../utils/git'
require_relative '../utils/helper'

module VHP
  class CommitLoader
    include Paths

    def initialize(cli_options)
      @clean = cli_options[:clean].key?
      @repo = project_source_repo(cli_options['repo'])
    end

    def add_mentioned_commits
      puts "Adding commit with options: #{@options}"

      saver = GitSaver.new(@options[:repo], @options[:gitlog_json])
      failed = []

      puts "Traversing CVE ymls"
      shas = []
      Dir["#{@options[:cves]}/**/*.yml"].each do |file|
        yml = YAML.load(File.open(file))
        unless yml['fixes'].nil?
          shas += yml['fixes'].map { |fix| fix[:commit] || fix['commit'] }
        end
        unless yml['vccs'].nil?
          shas += yml['vccs'].map  { |vcc| vcc[:commit] || vcc['commit'] }
        end
        unless yml['interesting_commits']['commits'].nil?
          shas += yml['interesting_commits']['commits'].map  { |c| c[:commit] || c['commit'] }
        end
      end
      if File.file? 'commits/mega-commits.yml'
        puts "Handling known 'mega' commits"
        megas = YAML.load(File.open('commits/mega-commits.yml')) || []
        megas.each do |mega|
          shas.delete mega['commit']
          saver.add_mega(mega['commit'],
                         mega['note'],
                         @options[:skip_existing])
        end
      end

      puts "Getting git logs"
      shas.uniq.reject { |sha| sha.to_s.empty? }.each do |sha|
        # puts "Attempting to add: #{sha}"
        begin
          saver.add(sha, @options[:skip_existing])
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
