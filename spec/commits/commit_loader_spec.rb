require_relative '../helper'

describe VHP::CommitLoader do

  subject { VHP::CommitLoader.new({:clean => 'clean', :repo => this_repo })}

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
      expect(git_api).to receive(:save).with(/081af3640e/, true)
      expect(git_api).to receive(:save).with(/138c9ba0cc/, true)
      expect(git_api).to receive(:save_to_json)
      expect(git_api).to receive(:gitlog_size).and_return(0)
      subject.add_mentioned_commits
    end

  end
end
