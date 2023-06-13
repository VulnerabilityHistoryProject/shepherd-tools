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

    desc 'update [OPTIONS]'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :nvd_repo,  'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)', required: true, type: :string
    option :kernel_cves, "Directory of the kernel CVE repo (https://github.com/nluedtke/linux_kernel_cves)"
    def update
      VHP::Update.new(options['project'],
                      options['kernel_cves'],
                      options['nvd_repo']).run
    end

    desc 'new [OPTIONS]'
    option :project, banner: 'Shortname (subdomain) of the project to lookup', required: true, type: :string
    option :nvd_repo, banner: 'Directory of the NVD repo (from: https://github.com/olbat/nvdcve)', required: true
    option :cve, banner: 'Format CVE-YYYY-NNNN, must exist in the NVD already', required: true, type: :string
    option :force, banner: "Overwrite the YML file if it exists"
    def new
      VHP::NewCVE.new(options['project'],
                      options['cve'] ,
                      options['nvd_repo']).run
    end

		def self.exit_on_failure?
			true
		end
	end
end
