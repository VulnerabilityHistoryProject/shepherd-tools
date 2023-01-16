require_relative '../paths'
require_relative '../yml_helper'
require 'httparty'

module VHP
  class NVDLoader
    include Paths
    include YMLHelper

    def initialize(opts)
      raise '--project required' unless opts.key? :project
      @project = opts[:project]
      @sleep_time = 5
      @http_opts = {
        read_timeout: 3
      }
      if opts[:apikey].nil?
        puts "WARN: No API key specified, so the NVD will likely throttle us. Sleeping #{@sleep_time} seconds "
      else
        @http_opts[:headers] = { apiKey: File.read(opts[:apikey]).strip }
      end
    end

    # def run
    #   base_url = "https://services.nvd.nist.gov/rest/json/cve/1.0/"
    #   errors = []
    #   cve_ymls.each do |filename|
    #     begin
    #       cve = File.basename(filename, '.yml')
    #       r = HTTParty.get(base_url + cve, @http_opts).parsed_response
    #       puts "Sleeping."
    #       sleep 0.5
    #       cvss = r.dig("result",
    #                   "CVE_Items",
    #                   0,
    #                   "impact",
    #                   "baseMetricV2",
    #                   "cvssV2",
    #                   "vectorString").to_s
    #       published = r.dig("result",
    #                   "CVE_Items",
    #                   0,
    #                   "publishedDate")
    #       cvss2_regex = %r{^AV:./AC:./Au:./C:./I:./A:.$}
    #       cvss3_regex = %r{^AV:./AC:./PR:./UI:./S:./C:./I:./A:.$}

    #       if cvss3_regex.match?(cvss) || cvss2_regex.match?(cvss)
    #         yml_string = File.open(filename, 'r') { |f| f.read }
    #         # default to announced == published until curators correct it
    #         yml_string = yml_string.gsub(/announced_date:\s*\r?\n/, "announced_date: #{published}\n")
    #         yml_string = yml_string.gsub(/published_date:\s*\r?\n/, "published_date: #{published}\n")
    #         yml_string += "\nCVSS: #{cvss}\n"
    #         File.open(filename, 'w') do |f|
    #           f.write yml_string
    #         end
    #         print '.'
    #       else
    #         errors <<  "Could not find CVSS string for #{filename}, cvss string: #{cvss}"
    #       end
    #     rescue => e
    #       errors << "Exception on #{filename}: #{e.message}"
    #     end
    #   end
    #   errors.each { |e| warn e }
    # end

    def run
      puts <<~EOS
        . CVE YML written
        E there was an error on that. Aggregated and printed at the end.
      EOS
      errors = {}
      yml_files = Dir["cves/#{@project}/*.yml"].to_a
      yml_files.each do |yml_file|
        begin
          process_cve(yml_file)
          print '.'
          sleep @sleep_time
        rescue => e
          errors[yml_file] = e.message
          print 'E'
          # require 'byebug'; byebug
        end
      end
      errors.each {|file,msg | puts "==== ERROR ON #{file} ====\n#{msg}" }
      puts <<~EOS

      ✅Done! Processed #{yml_files.size} YMLs
      There were #{errors.size} errors.

      ERROR
      EOS
    end

    def process_cve(yml_file)
			yml = load_yml_the_vhp_way(yml_file)
      cve = yml[:CVE]
      r = pull_from_nvd(cve)

      # yml = attempt_cvss(yml, r)
      yml = attempt_dates(yml, r)
      yml = attempt_fixes(yml, r)
      yml = attempt_cwe(yml, r)
			write_yml_the_vhp_way(yml, yml_file)
		end

		def pull_from_nvd(cve)
			url = "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=#{cve}"
			return HTTParty.get(url, @http_opts)
		end

    # Disabling to get things working for now

		# def attempt_cvss(yml, r)
		# 	cvss = r.dig("vulnerabilities",
		# 								0,
		# 								"cve",
		# 								"metrics",
		# 								"cvssMetricV31",
		# 								0,
		# 								"cvssData",
		# 								"vectorString").to_s
		# 	cvss3_regex = %r{^CVSS:3.1/AV:./AC:./PR:./UI:./S:./C:./I:./A:.$}
		# 	if cvss3_regex.match?(cvss)
		# 		yml[:CVSS] = cvss
		# 		puts "✅ CVSS loaded"
		# 	else
		# 		puts "[WARN] No CVSS found"
		# 	end
		# 	return yml
		# end

		def attempt_dates(yml, r)
			published = r.dig("vulnerabilities",0, "cve", "published")
			if published.nil?
				puts "[WARN] Published date not found."
			else
				yml[:published_date] = published
			end
			return yml
		end

		def attempt_fixes(yml, r)
			refs = r.dig("vulnerabilities",0, "cve","references")
			fix_regex = /git.*(?<sha>[0-9a-z]{40})/
			refs&.each do |ref|
				url = ref["url"]
				if fix_regex.match?(url)
					sha = fix_regex.match(url)[:sha]
					yml[:fixes] << {
						commit: sha,
						note: <<~EOS
							Taken from NVD references list with Git commit. If you are
							curating, please fact-check that this commit fixes the vulnerability and replace this comment with 'Manually confirmed'
						EOS
					} unless yml[:fixes].any? { |f| f[:commit] == sha } # already saved
				end
			end
			return yml
		end

		def attempt_cwe(yml, r)
			weaknesses = r.dig("vulnerabilities",0, "cve","weaknesses")
			cwe_regex = /CWE\-(?<cwe>\d+)/
			weaknesses&.each do |weak|
				weak_str = weak.to_s
				if cwe_regex.match?(weak_str)
					yml[:CWE] ||= []
					yml[:CWE] << cwe_regex.match(weak_str)[:cwe].to_i
					yml[:CWE_note] = <<~EOS
						CWE as registered in the NVD. If you are curating, check that this
						is correct and replace this comment with "Manually confirmed".
					EOS
					yml[:CWE].uniq!
				end
			end
			return yml
		end
  end
end