# Intended to be included so you can get paths easily
module VHP
  module Paths
    def migration_dir
      File.expand_path './migrations'
    end

    def new_migration(f)
      File.expand_path "#{migration_dir}/#{f}"
    end

    def migration_template
      File.expand_path "#{__dir__}/migrate/migration_template.rb.txt"
    end

    def gitlog_json(mining_path, project)
      File.expand_path "#{mining_path}/gitlogs/#{project}.json"
    end

    def project_yml_file(p)
      File.expand_path "./projects/#{p}.yml"
    end

    def projects
      Dir["./cves/*"].map {|d| d.match(%r{cves/(?<project>\w+)})[:project] }
    end

    def project_source_repo(user_supplied)
      begin
        p = user_supplied.to_s.empty? ? './tmp/src' : user_supplied
        return File.expand_path p
      rescue => e
        warn "Project source repo expected at: #{p}. #{e.message}"
      end
    end

    def project_from_file(f)
      f.match(%r{cves/(?<project>\w+)/.*.yml})[:project]
    end

    def cve_ymls(project="**")
      Dir["./cves/#{project}/*.yml"]
    end

    def weekly_json_count(project="**")
      Dir["#{@mining}/weeklies/#{@project}/*.json"].count
    end

    def weekly_file(cve)
      "#{@mining}/weeklies/#{@project}/#{cve.upcase}-weekly.json"
    end

  end
end
