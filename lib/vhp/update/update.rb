
module VHP
	class Update

		def initialize(project, kernel_cves, nvd_repo)
			@project = project.strip.downcase
			@kernel_cves = kernel_cves
			@nvd_repo = nvd_repo
		end

		def run
			puts "Finding updater for #{@project}..."
			new_cves = case @project
			when 'tomcat'
				VHP::UpdateTomcat.new.run
			when 'django'
				VHP::UpdateDjango.new.run
			when 'kernel'
				VHP::UpdateKernel.new(@kernel_cves).run
			else
				puts "[\e[31mERROR\e[0m] Updater not found for #{@project}. Looks like we haven't ported or written an updater for #{@project}. Check the deprecated [project]-vulnerabilities/scripts if we had any script from before."
				[]
			end
			puts "Found #{new_cves.size} CVEs: "
			puts new_cves.map {|k,v| "#{k}: #{v}"}.join("\n")
			puts "Creating YML entries..."
			create_cves(new_cves)
		end

		# new_cves is a hash of CVE ID to a list of fix commits
		def create_cves(new_cves)
			errors = {}
			new_cves.each do |cve, fixes_array|
				begin
					NewCVE.new(@project, cve, nvd_repo = @nvd_repo, fixes = fixes_array).run
				rescue => e
					errors[cve] = e.message
					puts "...skipping #{cve}"
				end
			end
			errors.each do |cve, err|
				puts "[\e[31mERROR\e[0m] on #{cve}: #{err}"
			end
			puts "\e[31mERROR\e[0ms: #{errors.size}" if errors.any?
		end
	end
end
