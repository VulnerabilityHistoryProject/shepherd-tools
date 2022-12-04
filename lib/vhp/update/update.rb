
module VHP
	class Update

		def initialize(args, options)
			@project = args[0].strip.downcase
			@check_only = options[:check_only]
		end

		def run
			puts "Finding updater for #{@project}..."
			case @project
			when 'tomcat'
			else
				puts "[\e[31mERROR\e[0m] Updater not found for #{@project}. Looks like we haven't ported or written an updater for #{@project}. Check the deprecated [project]-vulnerabilities/scripts if we had any script from before."
			end
		end
	end
end
