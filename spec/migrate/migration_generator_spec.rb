require_relative '../helper'

describe VHP::MigrationGenerator do

  context :run do

    it 'calls FileUtils' do
      expect(FileUtils).to receive(:cp).with(/migration_template/, /foobar/)
      silently do
        VHP::MigrationGenerator.new.run('foobar')
      end
    end

  end
end
