require 'git'
require 'json'
require 'yaml'
require 'fileutils'
require_relative '../utils/git'

module ShepherdTools
  class PublicVulnGenerator
    def gen_data(input_options)
      options = {}
      options[:gitlog_json] = gitlog_json(input_options)
      options[:repo] = repo(input_options)
      options[:cves] = cves(input_options)
      options[:skip_existing] = skip_existing(input_options)

      puts "Adding commit with options: #{options}"

      failed = []
      filepaths = []
      puts "Traversing CVE ymls"
      shas = []
      Dir["#{options[:cves]}/**/*.yml"].each do |file|
        yml = YAML.load(File.open(file))
        unless yml['fixes'].nil?
          shas += yml['fixes'].map { |fix| fix[:commit] || fix['commit'] }
        end
        shas.each do |sha|
          Dir.chdir(options[:repo]) do
            put '.'
            filepaths << `git log --stat -1 --pretty="" --name-only #{sha}`.split
          end
        end
      end
      filepaths = filepaths.flatten.sort.uniq.delete_if {|f| f == 'DEPS' }

      puts "Vulnerable files: #{filepaths}"

      puts "Getting file edits for #{filepaths.size} files"
      edit_shas = []
      Dir.chdir(options[:repo]) do
        filepaths.each do |filepath|
          puts "  running: git log --pretty=%H -- #{filepath}"
          edit_shas << `git log --pretty=\"%H\" -- #{filepath}`.split
        end
      end
      edit_shas = edit_shas.flatten.uniq
      puts "Getting git logs for #{edit_shas.size} commits"
      check_file_path(options[:gitlog_json])
      saver = GitSaver.new(options[:repo], options[:gitlog_json])
      edit_shas.each do |sha|
        begin
          saver.add(sha, options[:skip_existing])
        rescue
          puts "FAILED to add #{sha}"
          failed << sha
        end
        print '.'
      end
      saver.save

      puts 'The following commits could not be found:'
      pp failed
    end

    def check_file_path(path)
      dir = File.dirname(path)
      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      File.open(path, 'w+') {|file| file.write("{}")}
    end

    def gitlog_json(options)
      dir = 'commits/gitlog.json'
      if options.key? 'git_log.json'
        dir = options['git_log.json']
      end
      dir
    end

    def repo(options)
      repo = 'struts'
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
