# Intended to be included so you can get paths easily
module VHP::Paths

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
    File.expand_path(
      if user_supplied.to_s.empty?
        './tmp/src'
      else
        user_supplied
      end
    )
  end

end
