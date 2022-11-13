require 'git'
require 'json'
require_relative '../parallelism'
require_relative '../paths'

module VHP
  class GitAPI
    include Paths
    include Parallelism
    using StringRefinements

    attr_reader :git

    def initialize(mining_path, repo_path, project)
      @git = Git.open(repo_path)
      @repo = repo_path
      @gitlog_json_file = gitlog_json(mining_path, project)
      @gitlog = JSON.parse(File.read(@gitlog_json_file))
    end

    def gitlog_size
      @gitlog.size
    end

    # Lookup and save a commit
    # clean? Means don't skip existing
    def save(sha, clean = false)
      return {} if skip_existing?(sha, clean)

      @gitlog[sha] = {} # Even if it existed before, let's reset
      commit = @git.object(sha)
      diff = @git.diff(commit.parent, commit)
      @gitlog[sha][:author]     = commit.author.name
      @gitlog[sha][:email]      = commit.author.email
      @gitlog[sha][:date]       = commit.author.date.utc
      @gitlog[sha][:message]    = commit.message[0..1000]
      @gitlog[sha][:insertions] = diff.insertions
      @gitlog[sha][:deletions]  = diff.deletions
      @gitlog[sha][:filepaths]  = diff.stats[:files]
      return @gitlog[sha]
    end

    def save_to_json
      File.open(@gitlog_json_file, 'w') do |file|
        file.write(@gitlog.to_json)
      end
    end

    # Similar method as above, but not adding file info
    def save_mega(sha, curator_note, clean = false)
      return {} if skip_existing?(sha, clean)

      @gitlog[sha] = {} # Even if it existed before, let's reset
      commit = @git.object(sha)
      @gitlog[sha][:author]   = commit.author.name
      @gitlog[sha][:email]    = commit.author.email
      @gitlog[sha][:date]     = commit.author.date.utc
      @gitlog[sha][:filepaths]  = {}
      message = <<-EOS.strip_heredoc
        CURATOR NOTE
          This is a very large commit.
          The curators of VHP have decided not to show all of the file information for brevity.

        ORIGINAL MESSAGE: #{commit.message[0..1000]}
      EOS
      @gitlog[sha][:message]  = message
      return @gitlog[sha]
    end

    # Find all of the files impacted by the shas, calling get_files_in_commit
    def get_files_from_shas(commit_shas)
      files = []
      commit_shas.each do |sha|
        files += get_files_in_commit(sha)
      end
      return files.flatten.uniq
    end

    # Get the files that are in a commit
    # This is WAY faster than computing a diff because it's just a hash compare
    # not a gigantic string compare for each file
    def get_files_in_commit(sha)
      cmd = "git -C #{@repo} diff-tree --no-commit-id --name-only -r #{sha}"
      files = ""
      begin
        files = `#{cmd}`
      rescue => e
        warn "ERROR running #{cmd}: Message: #{e.message}"
        return []
      end
      return files.split("\n").to_a
    end

    # A drive-by author is one who has only made one commit to the repo, ever
    def get_drive_by_authors
      git_revlist = `git -C #{@repo} rev-list --all --pretty="%ae"`
      authors = git_revlist.split(/commit .+\n/).reject {|a| a.empty? }
      authors = authors.map { |a| a.downcase.strip }
      counts = Hash.new(0)
      authors.each { |a| counts[a] += 1 }
      counts.select { |a, count| count == 1 }.keys
    end

    def warn_megas
      megas = @gitlog.select do |_sha, log|
        log.key?(:filepaths) && log[:filepaths].size > 100
      end
      unless megas.empty?
        puts "WARN: Potential megas: "
        puts megas.map {|sha, log| "#{sha} #{log[:filepaths].size}" }
      end
    end

    private

    # What if the commit already exists in gitlog.json?
    # If we're not doing a clean build AND it exists, then skip
    def skip_existing?(sha, clean)
      if @gitlog.key? sha
        unless clean
          print "\n#{sha} already exists in gitlog.json, skipping"
          return true
        end
        puts "INFO: commit #{sha} already exists in gitlog.json. Will be overwritten."
      end
      return false
    end

  end
end
