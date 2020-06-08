require_relative 'helper'

describe VHP::Paths do

  subject { Object.new.extend(VHP::Paths) }

  context :new_migration do
    it 'resolves properly' do
      expect(subject.new_migration('foobar')).to match("/migrations/")
    end
  end

  context :migration_template do
    it 'resolves properly' do
      expect(subject.migration_template).to match(/migration_template.rb.txt/)
    end
  end
end
