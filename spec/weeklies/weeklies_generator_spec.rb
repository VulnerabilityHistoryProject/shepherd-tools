require_relative '../helper'

describe VHP::WeekliesGenerator do

  let(:expected) do
    {
      1505=> {
        :date=>Time.parse('2020-06-08 00:00:00 -0400'),
        :commits=>3,
        :insertions=>2,
        :deletions=>2,
        :files_added => 1,
        :files_deleted => 1,
        :files_renamed => 0,
        :reverts=>0,
        :rolls=>0,
        :refactors=>0,
        :test_files=>0,
        :files=>["vulnerable_file.rb"],
        :developers=>["andy@se.rit.edu"],
        :new_developers=>["andy@se.rit.edu"],
        :drive_bys=>[],
        :ownership_change=>false
      }
    }
  end

  around(:each) do |example|
    Dir.chdir(foo_dir) do
      silently do
        example.run
      end
    end
  end

  context :run do
    it 'loads our example properly' do
      file = double('file')
      expect(File).to receive(:open).and_yield(file)
      expect(file).to receive(:write)
      expect(JSON).to receive(:fast_generate).with(expected)
      VHP::WeekliesGenerator.new({ clean: true, repo: this_repo }).run
    end
  end
end
