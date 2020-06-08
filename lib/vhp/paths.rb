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

    def project_source_repo(user_supplied)
      File.expand_path(user_supplied.to_s.empty? ? './tmp/src' : user_supplied)
    end

    def cve_ymls
      Dir["./cves/**/*.yml"]
    end
  end
end
