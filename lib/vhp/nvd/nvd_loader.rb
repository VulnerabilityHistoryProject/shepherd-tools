require_relative '../paths'
require_relative '../yml_helper'
require 'httparty'

module VHP
  class NVDLoader
    include Paths
    include YMLHelper

    def initialize(project, nvd_repo, cve)
      @project = project
      @nvd_repo = nvd_repo
      @cve = cve
    end

    def run
      puts <<~EOS
        . CVE YML written
        E there was an error on that. Aggregated and printed at the end.
      EOS
      errors = {}
      yml_files = if @cve.nil? # do the whole project
        Dir["cves/#{@project}/*.yml"].to_a
      else
        ["cves/#{@project}/#{@cve}.yml"] # just the one
      end

      yml_files.each do |yml_file|
        begin
          process_cve(yml_file)
          print '.'
          sleep @sleep_time if @nvd_repo.nil?
        rescue => e
          errors[yml_file] = e.message
          print 'E'
          # require 'byebug'; byebug
        end
      end
      errors.each {|file,msg | puts "==== ERROR ON #{file} ====\n#{msg}" }
      puts <<~EOS

        ✅ Done! Processed #{yml_files.size} YMLs
        There were #{errors.size} errors.
      EOS
    end

    def process_cve(yml_file)
			yml = load_yml_the_vhp_way(yml_file)
      cve = yml[:CVE]
      r = pull_from_nvd(cve)

      yml = attempt_cvss(yml, r)
      yml = attempt_dates(yml, r)
      yml = attempt_fixes(yml, r)
      yml = attempt_cwe(yml, r)
			write_yml_the_vhp_way(yml, yml_file)
		end

		def pull_from_nvd(cve)
      return JSON.parse(File.read("#{@nvd_repo}/nvdcve/#{cve}.json"))
		end

    def attempt_cvss(yml, r)
			# Just convert r to a string and regex search for the vector string for crying out loud. this json is so annoying...
			cvss3_regex = %r{CVSS:3.1/AV:./AC:./PR:./UI:./S:./C:./I:./A:.}
			nvd_string = r.to_s
			if cvss3_regex.match?(nvd_string)
				yml[:CVSS] = nvd_string[cvss3_regex]
			end
			return yml
		end

		def attempt_dates(yml, r)
			published = r.dig("publishedDate")
			if published.nil?
				puts "[WARN] Published date not found."
			else
        yml[:published_date] = Date.strptime(published).strftime('%Y-%m-%d')
			end
			return yml
		end

		def attempt_fixes(yml, r)
			refs = r.dig("cve","references", "reference_data")
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
			weaknesses = r.dig("vulnerabilities",0, "cve","problemtype")
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