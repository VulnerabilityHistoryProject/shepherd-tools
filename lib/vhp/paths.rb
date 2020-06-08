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

end
