require_relative '../paths'
require_relative '../yml_helper'

module VHP
	class NewCVE
		include YMLHelper
		include Paths

		def initialize(project, cve, skip_nvd, nvd_repo = '', apikey = nil)
			@project = project
			@cve = cve
			@skip_nvd = skip_nvd
			@apikey = apikey
			@nvd_repo = nvd_repo
		end

		def run
			puts "Loading skeleton for cves/#{@project}/#{@cve}.yml..."
			yml = load_yml_the_vhp_way("skeletons/#{@project}.yml")
			yml[:CVE] = @cve
			unless @skip_nvd
				puts "Looking up NVD data..."
				r = pull_from_nvd
				binding.irb
				yml = attempt_cvss(yml, r)
				yml = attempt_dates(yml, r)
				yml = attempt_fixes(yml, r)
				yml = attempt_cwe(yml, r)
			end

			outfile = "cves/#{@project}/#{@cve}.yml"
			write_yml_the_vhp_way(yml, outfile)
			puts "✅ Done! Written #{outfile}."
		end

		def pull_from_nvd()
			if @nvd_repo.empty?
				url = "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=#{@cve}"
				# http_opts = {}
				# http_ops[:headers] = { apiKey: @apikey } if @apikey
				r = HTTParty.get(url)
				return r.dig("vulnerabilities", 0)
			else
				return JSON.parse(File.read("#{@nvd_repo}/nvdcve/#{@cve}.json"))
			end
		end

		def attempt_cvss(yml, r)
			# Just convert r to a string and regex search for the vector string for crying out loud. this json is so annoying...
			cvss3_regex = %r{CVSS:3.1/AV:./AC:./PR:./UI:./S:./C:./I:./A:.}
			nvd_string = r.to_s
			if cvss3_regex.match?(nvd_string)
				yml[:CVSS] = nvd_string[cvss3_regex]
				puts "✅ CVSS loaded"
			else
				puts "[WARN] No CVSS found"
			end
			return yml
		end

		def attempt_dates(yml, r)
			published = r.dig("vulnerabilities",0, "cve", "published")
			if published.nil?
				puts "[WARN] Published date not found."
			else
				yml[:published_date] = published
				puts "✅ Published date loaded"
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
					puts "✅ Fix #{sha} found"
				end
			end
			return yml
		end

		def attempt_cwe(yml, r)
			weaknesses = r.dig("cve","problemtype")
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
					puts "✅ CWE added"
				end
			end
			return yml
		end
	end
end