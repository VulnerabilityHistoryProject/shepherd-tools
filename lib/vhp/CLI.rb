require 'thor'

module VHP
	class CLI < Thor
		desc "version", "show the version"
		def version
			puts "VHP command line tools v#{VHP::VERSION}"
		end

		def self.exit_on_failure?
			true
		end
	end
end