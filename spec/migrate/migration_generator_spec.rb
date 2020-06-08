require_relative '../helper'

describe VHP::MigrationGenerator do
  context :run do
    it 'calls FileUtils for a system file copy' do
      expect(FileUtils).to receive(:cp).with(/tion_template\.rb\.txt/, /foobar/)
      VHP::MigrationGenerator.new.run "foobar"
    end
  end
end
