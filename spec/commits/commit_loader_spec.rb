require_relative '../helper'

describe VHP::CommitLoader do

  subject { VHP::CommitLoader.new({
    clean: 'clean',
    repo: this_repo,
    project: 'foo',
    mining: mining_dir,
  })}

  around(:each) do |example|
    Dir.chdir(foo_dir) do
      silently do
        example.run
      end
    end
  end

  context :add_mentioned_commits do

    it 'properly loads gitlog.json with some mentioned commits' do
      git_api = double(VHP::GitAPI)
      expect(VHP::GitAPI).to receive(:new).and_return(git_api)
      expect(git_api).to receive(:save).with(/3711df67d3/, true)
      expect(git_api).to receive(:save).with(/4a980d0887/, true)
      expect(git_api).to receive(:warn_megas)
      expect(git_api).to receive(:save_to_json)
      expect(git_api).to receive(:gitlog_size).and_return(0)
      subject.add_mentioned_commits
    end

  end
end
