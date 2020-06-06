require 'git'
require 'json'
require 'yaml'
require 'fileutils'
require_relative '../utils/git'
require_relative '../utils/helper'

module VHP
  class CommitLoader
    def initialize(input_options)
      @options = {}
      @options[:gitlog_json] = gitlog_json(input_options)
      VHP.check_file_path(@options[:gitlog_json], 'json')
      @options[:repo] = VHP.handle_repo(input_options)
      @options[:cves] = VHP.handle_cves(input_options)
      @options[:skip_existing] = skip_existing(input_options)
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

    def gitlog_json(options)
      dir = 'commits/gitlog.json'
      if options.key? 'git_log.json'
        dir = options['git_log.json']
      end
      dir
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
