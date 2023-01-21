require 'httparty'

require 'yaml'

module VHP
	class UpdateDjango
		include YMLHelper
		include Paths

		def initialize
			@url = "https://raw.githubusercontent.com/django/django/main/docs/releases/security.txt"
		end

		def run
			print "Downloading from #{@url}..."
			response = HTTParty.get(@url)
			raise "Error downloading: #{response.message}" unless response.code == 200
			puts "✅"
			security_txt = response.body # this is a restructured text file
			security_txt.scan(/:cve:`[\d\-]*`/).each do |rst_cve|
				cve = cve_from_rst(rst_cve)
				puts "#{cve} ..... #{yml_exists?(cve)}"
			end
		end

		def yml_exists?(cve)
			File.exist? "cves/django/#{cve}.yml"
		end

		def cve_from_rst(rst_cve)
			cve = rst_cve.match(/:cve:`([\d\-]*)`/).captures[0]
			return "CVE-#{cve}"
		end

	end
end