require 'httparty'
require_relative '../paths'
require_relative '../yml_helper'

GIT_SHA_REGEX = /[0-9a-f]{40}/

module VHP
	class FixCrawl
		include Paths
		include YMLHelper

		def initialize(args, options)
			@repo_path = project_source_repo(options[:repo])
      @git = Git.open(@repo_path)
			@cve = args.first
			@yml_file = Dir["cves/**/#{@cve}.yml"].first
			@yml = load_yml_the_vhp_way(@yml_file)
		end

		def run
			puts "Getting existing commit hashes..."
			existing_shas = `git -C #{@repo_path} rev-list HEAD`.split

			puts "Getting NVD data for #{@cve}..."
			nvdurl = "https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=#{@cve}"
			r = HTTParty.get(nvdurl)
			urls = r.dig("vulnerabilities", 0, "cve", "references")
						  .select { |entry| entry["tags"].include? "Issue Tracking" }
							.map { |entry| entry["url"] }

			puts "Crawling Issue Tracking urls..."
			shas = []
			urls.each do |url|
				print '.'
				page = HTTParty.get(url)
				shas += page.body.scan(GIT_SHA_REGEX).uniq
			end
			puts '.'
			fix_shas = existing_shas.intersection(shas)
			puts "Found #{fix_shas.size} potential fix commits"

			fix_shas.each do |sha|
				if @yml[:fixes].any? { |fix| fix[:commit] == sha }
					puts "Fix SHA #{sha} already in #{@cve}.yml, skipping."
				else
					@yml[:fixes] << {
						commit: sha,
						note: <<~EOS
							Automatically discovered by VHP scripts. If you are curating,
							please check that this fix commit is accurate, then replace this
							comment with "Fix commit confirmed" and any other observations.

							If this commit is NOT the fix for the vulnerability, please remove this entry.
						EOS
					}
					puts "Fix SHA #{sha} inserted into #{@cve}.yml"
				end
			end
			puts "Writing #{@cve}.yml..."
			write_yml_the_vhp_way @yml, @yml_file
			puts "Done!"
		end
	end
end