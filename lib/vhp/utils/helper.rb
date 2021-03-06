require 'fileutils'
module VHP
  def self.read_file(file_path)
    if File.file?(file_path)
      return File.read(file_path).chomp
    else
      return nil
    end
  end

  def self.handle_csv(path)
    if path.nil?
      path = 'csvs'
    else
      path_ar = path.split(/[\,\/]/)
      os_path = nil
      for dir in path_ar
        os_path = File.join(path, dir)
      end
      os_path = File.join(path, 'csvs')
    end
    unless File.directory?(os_path)
      FileUtils.mkdir_p(os_path)
    end
    return os_path
  end

  def self.find_CVE_dir
    puts File.basename(Dir.getwd)
    if(File.basename(Dir.getwd).eql? 'shepherd-tools')
      subdirs = Dir.glob('../**/')
    else
      subdirs = Dir.glob('**/')
    end
    cve_path = ''
    subdirs.each do |dir|
      if(/cves\/$/.match(dir)!=nil)
        cve_path = dir.chomp('/')
        break
      end
    end
    cve_path
  end

  def self.handle_cves(options)
    cves = 'cves'
    if options.key? 'cves'
      cves = options['cves']
    end
    cves
  end

  def self.handle_repo(options)
    repo = Dir.pwd
    if options.key? 'repo'
      repo = options['repo']
    end
    repo
  end

  def self.check_file_path(path, type)
    dir = File.dirname(path)
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
    if type.eql? 'json'
      File.open(path, 'w+') {|file| file.write("{}")}
    else
      FileUtils.touch(path)
    end
  end

end
