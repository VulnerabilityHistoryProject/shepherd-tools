require 'git'

module ShepherdTools
  class GitLog
    def initialize(repo)
      @git = Git.open(repo)
    end

    def get_files_from_hash(commit_hashes)
      files = []
      commits_hashes.each do |hash|
        commit = @git.object(hash)
        diff = @git.diff(commit, commit.parent)
        files << diff.stats[:files].keys
      rescue #catch file not found exception
      end
      return files.flatten.uniq
    end
  end
end
