require 'git'
require 'json'

module VHP
  class GitLog
    def initialize(repo)
      @git = Git.open(repo)
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

  end

  class GitSaver
    def initialize(repo, gitlog_json)
      puts repo
      @git = Git.open(repo)
      @gitlog_json = gitlog_json
      gitlog = File.read(gitlog_json)
      @gitlog = JSON.parse(gitlog)
    end

    # Lookup and save a commit
    def add(sha, skip_existing = true)
      if @gitlog.key? sha
        if skip_existing
          puts "#{sha} already exists in gitlog.json, skipping"
          return
        end
        puts "WARNING! Commit #{sha} already exists in gitlog.json. Will be overwritten."
      end

      @gitlog[sha] = {} # Even if it existed before, let's reset
      commit = @git.object(sha)
      diff = @git.diff(commit, commit.parent)
      @gitlog[sha][:commit]     = sha
      @gitlog[sha][:author]     = commit.author.name
      @gitlog[sha][:email]      = commit.author.email
      @gitlog[sha][:date]       = commit.author.date
      @gitlog[sha][:message]    = commit.message.
                                    gsub('\n', '\\n').
                                    gsub('"', '&quot')[0..2000]
      @gitlog[sha][:insertions] = diff.insertions
      @gitlog[sha][:deletions]  = diff.deletions
      @gitlog[sha][:churn]      = @gitlog[sha][:insertions].to_i +
                                  @gitlog[sha][:deletions].to_i
      @gitlog[sha][:filepaths]  = diff.stats[:files]
    end

    def save
      File.open(@gitlog_json, 'w') do |file|
        file.write(@gitlog.to_json)
      end
    end

    # Similar method as above, but not adding file info
    def add_mega(sha, curator_note, skip_existing = true)
      if @gitlog.key? sha
        if skip_existing
          puts "#{sha} already exists in gitlog.json, skipping"
          return
        end
        warn "WARNING! Commit #{sha} already exists in gitlog.json. Will be overwritten."
      end

      @gitlog[sha] = {} # Even if it existed before, let's reset
      commit = @git.object(sha)
      @gitlog[sha][:commit]   = sha
      @gitlog[sha][:author]   = commit.author.name
      @gitlog[sha][:email]    = commit.author.email
      @gitlog[sha][:date]     = commit.author.date
      @gitlog[sha][:message]  = curator_note +
                                  commit.message.
                                    gsub('\n', '\\n').
                                    gsub('"', '&quot')[0..2000]
      @gitlog[sha][:filepaths]  = {}
    end

  end
end
