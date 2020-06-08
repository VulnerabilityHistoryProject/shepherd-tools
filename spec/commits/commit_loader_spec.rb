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
      saver = double(VHP::GitSaver)
      expect(VHP::GitSaver).to receive(:new).and_return(saver)
      expect(saver).to receive(:add).with(/081af3640e/, true)
      expect(saver).to receive(:add).with(/138c9ba0cc/, true)
      expect(saver).to receive(:add_mega).with(/8fc950b705/, /.*/, true)
      expect(saver).to receive(:save)
      subject.add_mentioned_commits
    end

  end
end
