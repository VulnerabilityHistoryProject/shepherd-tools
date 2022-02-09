require_relative '../yml_helper'
require_relative '../paths'
module VHP
  class FixCorpus
    include YMLHelper
    include Paths

    def initialize(options)
      clean if options[:clean]
      @repo_path = project_source_repo(options[:repo])
      @git = Git.open(@repo_path)
    end

    def clean
      FileUtils.rm("./tmp/fix-corpus", force: true)
    end

    def process_fix(fix, before_dir, after_dir)
      sha = fix[:commit].to_s
      begin
        unless sha.empty?
          # puts `git show #{sha}:`
          # binding.irb

          commit = @git.gcommit(sha)

          if commit.diff_parent.count > 20
            puts "sha: #{sha} has LOTS of files, skipping"
          else
            commit.diff_parent.each do |file_diff|
              unslashed_path = file_diff.path.gsub('/','-')
              # binding.irb
              File.open("#{before_dir}/#{unslashed_path}","w+") do |f|
                f.write file_diff.blob(:src)&.contents
              end

              File.open("#{after_dir}/#{unslashed_path}","w+") do |f|
                f.write file_diff.blob(:dst)&.contents
              end

            end
            print '.'
          end

          # binding.irb
          # commit.diff_parent.

        end
      rescue => e
        puts "ERROR on #{f} in sha #{sha}: #{e.message}"
        binding.irb
      end
    end

    def make_directories(cve)
      cve_dir = "tmp/fix-corpus/#{cve}"
      Dir.mkdir(cve_dir) unless File.exists?(cve_dir)
      before = "#{cve_dir}/before"
      after = "#{cve_dir}/after"
      Dir.mkdir(before) unless File.exists?("#{cve_dir}/before")
      Dir.mkdir(after)  unless File.exists?("#{cve_dir}/after")
      return before,after
    end

    def run
      Dir.mkdir("tmp/fix-corpus") unless File.exists?('tmp/fix-corpus')
      cve_ymls.each do |f|
        yml = load_yml_the_vhp_way(f)
        before_dir,after_dir = make_directories(yml[:CVE])
        yml[:fixes].each do |fix|
          process_fix(fix, before_dir, after_dir)
        end
      end
      puts "Fix corpus is in #{File.expand_path('tmp/fix-corpus')}"
    end

  end
end
