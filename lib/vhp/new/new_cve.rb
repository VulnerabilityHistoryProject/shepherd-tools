require_relative '../paths'
require_relative '../yml_helper'

module VHP
	class NewCVE
		include YMLHelper
		include Paths

		def initialize(project, cve, skip_nvd)
			@project = project
			@cve = cve
			@skip_nvd = skip_nvd
		end

		def run
			puts "Loading skeleton for cves/#{@project}/#{@cve}.yml..."
			yml = load_yml_the_vhp_way("skeletons/#{@project}.yml")
			yml[:CVE] = @cve
			unless @skip_nvd
				puts "Looking up NVD data..."
				url = "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=#{@cve}"
				r = HTTParty.get(url)
				yml = attempt_cvss(yml, r)
				yml = attempt_dates(yml, r)
				yml = attempt_fixes(yml, r)
				yml = attempt_cwe(yml, r)
			end

			outfile = "cves/#{@project}/#{@cve}.yml"
			write_yml_the_vhp_way(yml, outfile)
			puts "✅ Done! Written #{outfile}."
		end

		def attempt_cvss(yml, r)
			cvss = r.dig("vulnerabilities",
										0,
										"cve",
										"metrics",
										"cvssMetricV31",
										0,
										"cvssData",
										"vectorString").to_s
			cvss3_regex = %r{^CVSS:3.1/AV:./AC:./PR:./UI:./S:./C:./I:./A:.$}
			if cvss3_regex.match?(cvss)
				yml[:CVSS] = cvss
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
							curating, replace this comment with 'Manually confirmed'
						EOS
					}
					puts "✅ Fix #{sha} found"
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
					yml[:CWE] << cwe_regex.match(weak_str)[:cwe]
					yml[:CWE_note] = <<~EOS
						CWE as registered in the NVD. If you are curating, check that this
						is correct and replace this comment with "Manually confirmed".
					EOS
					puts "✅ CWE added"
				end
			end
			return yml
		end

	end
end