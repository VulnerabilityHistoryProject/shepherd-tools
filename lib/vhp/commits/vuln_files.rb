require 'csv'
require 'date'
require_relative '../cve_info/list_fixes'
require_relative '../utils/git'

module ShepherdTools
  class VulnerableFileExtractor
    def initialize(input_options)
      @options = {}
      @options[:cves] = ShepherdTools.handle_cves(input_options)
      @options[:repo] = ShepherdTools.handle_repo(input_options)
      @options[:period] = handle_period(input_options)
      @options[:output] = handle_output(input_options, @options[:period])
      ShepherdTools.check_file_path(@options[:output], 'csv')
    end

    def extract
      puts 'Getting vulnerable files list'
      tmpFixes = ListFixes.new(@options[:cves]).get_fixes
      fixes = []
      if @options[:period].eql? 'all_time'
        puts 'Period: all time'
        fixes = tmpFixes
      else
        puts 'Period: 6 months'
        Dir.chdir(@options[:repo]) do
          tmpFixes.each do |fix|
            gitLogCommand = "git log --before=#{end_date} --after=#{start_date} "+'--pretty=format:"%H" ' + fix + ' -1'
            check = `#{gitLogCommand}`
            if fix.to_s == check.chomp.to_s
              fixes << fix
            end
          end
        end
      end
      result = GitLog.new(@options[:repo]).get_files_from_shas(fixes)
      puts "Writing output file #{@options[:output]}"
      CSV.open(@options[:output], 'w+') do |csv|
        csv << [ 'filepath' ]
        result.each {|f| csv << [f]}
      end
    end

    def start_date
      start_date = Date.new(1991, 8, 5)
      if @options[:period].eql? '6_month'
        start_date = Date.today << 6
      end
      start_date.strftime "%Y.%m.%d"
    end

    def end_date
      Date.today.strftime "%Y.%m.%d"
    end

    def handle_output(options, period)
      substring = '-vulnerabilities'
      repo = ''
      if options.key? 'output'
        output = options['output']
      else
        Pathname(Dir.pwd).each_filename do |folder|
          if folder.include? substring
            repo = folder.chomp(substring)
          end
        end
        if repo.eql? ''
          raise 'Please run shepherd tools in a vulnerability repo'
        end
        output = "commits/public_vulns-#{repo}-#{period}.csv"
      end
      output
    end

    def handle_period(options)
      period = 'all_time'
      if options.key? 'period'
        if options['period'].eql? '6_months'
          period = '6_month'
        else
          period = options['period']
        end
      end
      period
    end

  end
end
