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

    def gitlog_json
      File.expand_path './commits/gitlog.json'
    end

    def project_yml
      File.expand_path './project.yml'
    end

    def project_source_repo(user_supplied)
      begin
        p = user_supplied.to_s.empty? ? './tmp/src' : user_supplied
        return File.expand_path p
      rescue => e
        warn "Project source repo expected at: #{p}. #{e.message}"
      end
    end

    def cve_ymls
      Dir["./cves/**/*.yml"]
    end

    def weekly_dir
      File.expand_path './commits/weeklies'
    end

    def weekly_file(cve)
      "#{weekly_dir}/#{cve.upcase}-weekly.json"
    end

  end
end
