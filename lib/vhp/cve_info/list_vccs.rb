module VHP
  class ListVCCs
    def initialize(cve_ymls = 'cves')
      @cve_ymls = Dir["#{cve_ymls}/*.yml"]
    end

    def self.new_CLI(options)
      self.new(VHP.handle_cves(options))
    end

    def print_vccs
      puts "CVE,commit"
      @cve_ymls.each do |yml_file|
        begin
          cve = File.open(yml_file) { |f| YAML.load(f) }
          cve['vccs'].each do |vcc|
            sha = vcc['commit'].to_s +
                vcc[':commit:'].to_s +
                vcc[:commit].to_s
            unless sha.strip.empty?
              puts "#{cve['CVE']},#{sha}"
            end
          end
        rescue
          puts "ERROR on #{yml_file}"
          puts e.backtrace
        end
      end
    end

    def get_vccs
      vccs = []
      @cve_ymls.each do |yml_file|
        begin
          cve = File.open(yml_file) { |f| YAML.load(f) }
          if cve['vccs'].nil?
            puts "vccs nil for #{yml_file}"
          else
            cve['vccs'].each do |vcc|
              sha = vcc['commit'].to_s +
                  vcc[':commit:'].to_s +
                  vcc[:commit].to_s
              unless sha.strip.empty?
                vccs << sha
              end
            end
          end
        rescue => e
          puts "ERROR on #{yml_file}"
          puts e.backtrace
        end
      end
      return vccs
    end

    def print_missing_vccs
      @cve_ymls.each do |yml_file|
        cve = File.open(yml_file) { |f| YAML.load(f) }
        empty = true
        cve['vccs'].each do |vcc|
          sha = vcc['commit'].to_s +
              vcc[':commit:'].to_s +
              vcc[:commit].to_s
          empty = false unless sha.strip.empty?
        end
        puts cve['CVE'] if empty
      end
    end
  end
end
