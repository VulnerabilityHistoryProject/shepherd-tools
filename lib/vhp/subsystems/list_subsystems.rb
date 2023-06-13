
module VHP
	class ListSubsystems
		include YMLHelper
		include Paths

		def run
			report = {}
			cve_ymls.each do |file|
				yml = load_yml_the_vhp_way(file)
				project = project_from_file(file)
				cve = yml[:CVE]
				report[project] ||= {}
				Array(yml[:subsystem][:name]).each do |subsystem|
					report[project][subsystem] ||= []
					report[project][subsystem] << cve
				end
			end
			report.each do |(project, subsystems)|
				subsystems.each do |(subsystem, cves)|
					puts [
						project,
						subsystem,
						cves.join(',')
					].join("\t")
				end
			end
		end
	end
end