require 'json'
require 'yaml'

module VHP
	class UpdateKernel
		include YMLHelper
		include Paths

		def initialize(kernel_cves)
			@kernel_cves = kernel_cves
			if kernel_cves.to_s.empty?
				raise 'Need to specify the --kernel-cves option'
			end
		end

		def run
			json = JSON.parse(File.read("#{@kernel_cves}/data/kernel_cves.json"))
			new_cves = {}
			json.each do |(cve,data)|
				fixes = Array(data["fixes"]).flatten
				new_cves[cve] = fixes unless yml_exists?(cve)
			end
			return new_cves
		end

		def yml_exists?(cve)
			File.exist? "cves/kernel/#{cve}.yml"
		end

	end
end