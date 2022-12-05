
module VHP
	class Update

		def initialize(args, options)
			@project = args[0].strip.downcase
			@dry_run = options[:dry_run]
			@nvd = !options[:skip_nvd]
		end

		def run
			puts "Finding updater for #{@project}..."
			new_cves = case @project
			when 'tomcat'
				VHP::UpdateTomcat.new(@project).run
			else
				puts "[\e[31mERROR\e[0m] Updater not found for #{@project}. Looks like we haven't ported or written an updater for #{@project}. Check the deprecated [project]-vulnerabilities/scripts if we had any script from before."
				[]
			end
			puts "Found #{new_cves.size} CVEs"
			if @dry_run
				new_cves.keys.each { |key| puts key }
			else
				create_cves(new_cves) unless @check_only
			end

		end

		# new_cves is a hash of CVE ID to a list of fix commits
		def create_cves(new_cves)
			errors = []
			puts new_cves

			errors.each do |err|
				puts "[\e[31mERROR\e[0m] #{err}"
			end
			puts "\e[31mERROR\e[0ms: #{errors.size}" if errors.size > 0

		end
	end
end
