require_relative '../migrate_tools'

def migrate()
  insert_text("CVE: CVE-\\d{4}-\\d+", "lib/shepherd_tools/migrate/test_file.txt", "after")
end

migrate()