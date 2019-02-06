def find_CVE_dir()
  subdirs = Dir.glob('**/')
  cve_path = ""
  subdirs.each do |dir|
    if(/cves\/$/.match(dir)!=nil)
      cve_path = dir
      break
    end
  end
  cve_path
end
