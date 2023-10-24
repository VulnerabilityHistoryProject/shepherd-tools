require 'thor'

module VHP
	class CLI < Thor
		desc "version",
         "Show the version of this CLI tool"
		def version
			puts "VHP command line tools v#{VHP::VERSION}"
		end

    desc 'migrate NAME',
         'Generate a skeleton migration file in ./migrations.'
    map migration: :migrate
    def migrate(name = 'migration')
      VHP::MigrationGenerator.new.run(name)
    end

    desc 'loadcommits [OPTIONS]',
         'Lookup mentioned commits in YMLs in the repository'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :repo, banner: 'Path to the project source code repository', required: true, type: :string
    option :mining, banner: 'Path to vhp-mining repo', required: true, type: :string
    option :clean, banner: "Dont' skip shas that already exist in the gitlog json"
    def loadcommits()
      loader = VHP::CommitLoader.new( options['project'],
                                      options['repo'],
                                      options['mining'],
                                      options.key?('clean'))
      loader.add_mentioned_commits
    end

    desc 'nvd [OPTIONS]',
         "Updates the project CVEs to get CVSS, announced, and fix data from NVD."
    option :project,  banner: 'Shortname (subdomain) of the project to lookup', required: true
    option :nvd_repo, banner: 'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)'
    option :cve,      banner: 'If specified, only update the one CVE. Otherwise, do the whole project', required: false, type: 'string'
    def nvd
      VHP::NVDLoader.new(options['project'],
                         options['nvd_repo'],
                         options['cve']).run
    end

    desc 'weeklies [OPTIONS]',
         'Mines project source repo for each week over time, saved in vhp-mining/weeklies'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :repo, banner: 'Path to the project source code repository', required: true, type: :string
    option :mining, banner: 'Path to vhp-mining repo', required: true, type: :string
    option :clean, banner: "Don't skip CVEs already saved. SLOW!"
    def weeklies
      WeekliesGenerator.new(options['project'],
                            options['repo'],
                            options['mining'],
                            options.key?('clean')).run
    end

    desc 'update [OPTIONS]', 'Check for an retrieve new CVEs for the given project'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :nvd_repo, banner: 'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)', required: true, type: :string
    option :kernel_cves, banner: "Directory of the kernel CVE repo (https://github.com/nluedtke/lcdinux_kernel_cves)"
    def update
      VHP::Update.new(options['project'],
                      options['kernel_cves'],
                      options['nvd_repo']).run
    end

    desc 'new [OPTIONS]', 'Create a new CVE file, looking up NVD info'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :nvd_repo, banner: 'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)', required: true
    option :cve, banner: 'Format CVE-YYYY-NNNN, must exist in the NVD already', required: true, type: :string
    option :force, banner: "Overwrite the YML file if it exists"
    def new
      VHP::NewCVE.new(options['project'],
                      options['cve'] ,
                      options['nvd_repo']).run
    end

    desc 'subsystems', 'List all subsystems for normalizing chore'
    def subsystems
       VHP::ListSubsystems.new.run
    end

    desc 'ready [OPTIONS]', 'List CVEs that are ready for curating'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :min_fixes, banner: 'Min number of fixes to show', type: :numeric , default: 1
    option :max_fixes, banner: 'Max number of fixes to show', type: :numeric , default: 5
    option :min_vccs,  banner: 'Min number of vccs to show', type: :numeric , default: 1
    option :max_vccs,  banner: 'Max number of vccs to show', type: :numeric , default: 5
    option :max_level, banner: 'Maximum curation level', type: :numeric , default: 0.0
    option :full, banner: 'Show all information in CSV format', type: :boolean
    def ready
      VHP::CurateReady.new( options['project'],
                            options['min_fixes'],
                            options['max_fixes'],
                            options['min_vccs'],
                            options['max_vccs'],
                            options['max_level'],
                            options.key?('full')
      ).print_readiness
    end

		def self.exit_on_failure?
			true
		end
	end
end
