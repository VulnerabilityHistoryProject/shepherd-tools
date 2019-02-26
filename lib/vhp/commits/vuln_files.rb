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
      period = calculate_period(input_options)
      @options[:start] = period[0]
      @options[:end] = period[1]
      period_name = handle_period_name(input_options, @options[:start], @options[:end])
      @options[:output] = handle_output(input_options, period_name, @options[:repo], @options[:start], @options[:end])
      ShepherdTools.check_file_path(@options[:output], 'csv')
    end

    def extract
      puts 'Getting vulnerable files list'
      tmpFixes = ListFixes.new(@options[:cves]).get_fixes
      fixes = []
      if @options[:start].nil? && @options[:end].nil?
        puts 'Period: all time'
        fixes = tmpFixes
      else
        puts "Period start: #{@options[:start]}"
        puts "Period end: #{@options[:end]}"
        Dir.chdir(@options[:repo]) do
          tmpFixes.each do |fix|
            gitLogCommand = "git log --before=#{@options[:end]} --after=#{@options[:start]} "+'--pretty=format:"%H" ' + fix + ' -1'
            check = `#{gitLogCommand}`
            if fix.to_s == check.chomp.to_s
              fixes << fix
            end
          end
        end
      end
      puts @Options[:repo]
      result = GitLog.new(@options[:repo]).get_files_from_shas(fixes)
      puts "Writing output file #{@options[:output]}"
      CSV.open(@options[:output], 'w+') do |csv|
        csv << [ 'filepath' ]
        result.each {|f| csv << [f]}
      end
    end

    def start_date(period)
      start_date = Date.new(1991, 8, 5)
      if period.eql? '6_month'
        start_date = Date.today << 6
      end
      start_date.strftime "%Y-%m-%d"
    end

    def today_date
      Date.today.strftime "%Y-%m-%d"
    end

    def handle_output(options, period_name, repo, start_date, end_date)
      output = 'commits'
      if options.key? 'output'
        output = options['output']
      end
      if File.directory? output
        repo_name = repo.split(File::SEPARATOR).last
        output = "#{output}/public_vulns-#{repo_name}-#{period_name}.csv"
      end
      output
    end

    def handle_period_name(options, start_date, end_date)
      period_name = "unamed_period"
      if options.key? 'period_name'
        period_name = options['period_name']
      elsif start_date.nil? && end_date.nil?
        period_name = 'all_time'
      elsif options.key? 'period'
        period_name = options['period']
      end
      period_name
    end

    def calculate_period(options)
      validate_options(options)
      period = Array.new(2)
      if options.key? 'period'
        if options['period'].eql? '6_month'
          period[0]=start_date(options['period'])
          period[1]=today_date
        end
      elsif (options.key? 'start') || (options.key? 'end')
        period[0]=start_date('all_time')
        period[1]=today_date
        if options.key? 'start'
          validate_date(options['start'])
          period[0]=options['start']
        end
        if options.key? 'end'
          validate_date(options['end'])
          period[1]=options['end']
        end
      end
      period
    end

    def validate_date(date)
      begin
        Date.strptime(date, "%Y-%m-%d")
      rescue ArgumentError
        raise "#{date} is an invalid date format. Please use YYYY.MM.DD"
      end
    end

    def validate_options(options)
      valid = ['all_time', '6_month']
      if (options.key? 'start') && (options.key? 'period')
        raise 'Invalid command. You can not give a start date with a period.'
      elsif (options.key? 'end') && (options.key? 'period')
        raise 'Invalid command. You can not give a end date with a period.'
      elsif (options.key? 'period') && !(valid.include? options['period'])
        raise "Invalid command. Not a valid period: #{options['period']}"
      end
    end

  end
end
