require 'git'
require 'json'
require_relative '../paths'

module VHP
  class GitAPI
    include Paths
    using StringRefinements

    def initialize(repo_path)
      @git = Git.open(repo_path)
      @gitlog = JSON.parse(File.read(gitlog_json))
    end

    # Lookup and save a commit
    # clean? Means don't skip existing
    def save(sha, clean = false)
      return {} if skip_existing?(sha, clean)

      @gitlog[sha] = {} # Even if it existed before, let's reset
      commit = @git.object(sha)
      diff = @git.diff(commit, commit.parent)
      @gitlog[sha][:commit]     = sha
      @gitlog[sha][:author]     = commit.author.name
      @gitlog[sha][:email]      = commit.author.email
      @gitlog[sha][:date]       = commit.author.date
      @gitlog[sha][:message]    = commit.message[0..1000]
      @gitlog[sha][:insertions] = diff.insertions
      @gitlog[sha][:deletions]  = diff.deletions
      @gitlog[sha][:churn]      = @gitlog[sha][:insertions].to_i +
                                  @gitlog[sha][:deletions].to_i
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
      @gitlog[sha][:commit]   = sha
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

    def get_files_from_shas(commit_shas)
      files = []
      commit_shas.each do |sha|
        commit = @git.object(sha)
        diff = @git.diff(commit, commit.parent)
        unless diff.stats[:files].nil?
          files << diff.stats[:files].keys
        end
      rescue #catch file not found exception
      end
      return files.flatten.uniq
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
