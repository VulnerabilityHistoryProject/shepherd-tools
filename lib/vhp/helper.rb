module ShepherdTools
  def self.read_file(file_path)
    if File.file?(file_path)
      return File.read(file_path).chomp
    else
      return nil
    end
  end

  def self.find_CVE_dir
    subdirs = Dir.glob('**/')
    puts subdirs
    cve_path = ""
    subdirs.each do |dir|
      if(/cves\/$/.match(dir)!=nil)
        cve_path = dir
        break
      end
    end
    cve_path
  end
end
