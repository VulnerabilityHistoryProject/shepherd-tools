require 'git'
require 'json'
require_relative '../parallelism'
require_relative '../paths'

module VHP
  class GitAPI
    include Paths
    include Parallelism
    using StringRefinements

    def initialize(repo_path)
      @git = Git.open(repo_path)
      @repo = repo_path
      @gitlog = JSON.parse(File.read(gitlog_json))
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
      diff = @git.diff(commit, commit.parent)
      @gitlog[sha][:author]     = commit.author.name
      @gitlog[sha][:email]      = commit.author.email
      @gitlog[sha][:date]       = commit.author.date
      @gitlog[sha][:message]    = commit.message[0..1000]
      @gitlog[sha][:insertions] = diff.insertions
      @gitlog[sha][:deletions]  = diff.deletions
      @gitlog[sha][:filepaths]  = diff.stats[:files]
      return @gitlog[sha]
    end

    def save_to_json
      File.open(gitlog_json, 'w') do |file|
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
      @gitlog[sha][:date]     = commit.author.date
      @gitlog[sha][:filepaths]  = {}
      message = <<-EOS.strip_heredoc
        CURATOR NOTE
          This is a very large commit.
          The curators of VHP have decided not to show all of the file information for brevity.
          Specifically, the curators stated:
            curator note!

        ORIGINAL MESSAGE: #{commit.message[0..2000]}
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

    private

    # What if the commit already exists in gitlog.json?
    # If we're not doing a clean build AND it exists, then skip
    def skip_existing?(sha, clean)
      if @gitlog.key? sha
        unless clean
          puts "#{sha} already exists in gitlog.json, skipping"
          return true
        end
        puts "INFO: commit #{sha} already exists in gitlog.json. Will be overwritten."
      end
      return false
    end

  end
end
