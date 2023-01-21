require 'mechanize'
require_relative '../paths'
require_relative '../yml_helper'
module VHP

	class UpdateTomcat
		include YMLHelper
		include Paths

		def tomcat_security_pages
			%w(
				https://tomcat.apache.org/security-10.html
				http://tomcat.apache.org/security-9.html
				http://tomcat.apache.org/security-8.html
				http://tomcat.apache.org/security-7.html
				http://tomcat.apache.org/security-6.html
				http://tomcat.apache.org/security-5.html
				http://tomcat.apache.org/security-4.html
				http://tomcat.apache.org/security-3.html
			)
		end

		def is_cve?(link)
			link.href.include? "cve.mitre.org"
		end

		def is_svn?(link)
			link.href.include? "svn.apache.org"
		end

		def is_git?(link)
			link.href.include? "github.com"
		end

		def get_cve(link)
			link.href.upcase.match( /(?<cvekey>CVE-[\-\d]+)/ )[:cvekey]
		end

		def get_svn_commit(link)
			link.href.upcase.match(/(?<svnid>\d+)/)[:svnid]
		end

		def get_git_commit(link)
			link.href.downcase.match(/(?<gitid>[\da-f]{40})/)[:gitid]
		end

		def crawl(url)
			puts "Crawling #{url}"
			cves = {}
			Mechanize.new.get(url) do |page|
				cur_cve = 'REPLACEME'
				page.links.each do | link |
					if is_cve?(link)
						cur_cve = get_cve(link)
						cves[cur_cve] = []
					else
						if is_svn?(link)
							cves[cur_cve] << get_svn_commit(link)
						elsif is_git?(link)
							cves[cur_cve] << get_git_commit(link)
						end
					end
				end
			end
			puts "Found #{cves.size} CVEs"
			return cves
		end

		# DISABLING this but we might use it again someday
		# Basically looks up git commits from SVN commits
		# But, they've moved onto git so we probably don't need it moving forward

		# def fix_ymlstr(cve, fixes)
		# 	ymlstr = fixes.inject("") do |str, fix|
		# 		git_sha = svn_id_to_git_sha(fix)
		# 		if git_sha.empty?
		# 			puts "WARN: git sha for svn r#{fix} not found in any repo for #{cve}"
		# 			''
		# 		else
		# 			str +
		# 				"   - commit: #{git_sha}\n" +
		# 				"     note: SVN rev #{fix}, from the Tomcat website.\n"
		# 		end
		# 	end
		# 	return "fixes:\n" + ymlstr + "   - commit:\n     note:\n"
		# end

		def get_current_cves
			Dir['cves/tomcat/*.yml'].map {|cve| cve[/CVE\-\d+\-\d+/] }
		end

		def run
			cur_cves = get_current_cves
			cves = {}
			tomcat_security_pages.each do |url|
				cves.merge! crawl(url) do |k, v1, v2|
					# CVEs can be on multiple pages, so merge the fix lists
					(v1 + v2).uniq
				end
			end
			puts "Total: #{cves.size} CVEs"
			cves.reject! {|cve, _value| cur_cves.include?(cve) }
			return cves
		end

	end
end