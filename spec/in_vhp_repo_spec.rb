require_relative 'helper'

describe VHP::InVHPRepo do
  it 'fails and warns on our root repo' do
    Dir.chdir(__dir__) do
      expect(subject).to receive(:warn).with(/not in a VHP/)
      expect(VHP::InVHPRepo.check_in_vhp_repo).to be false
    end
  end

  it 'detects foo-vulnerabilities' do
    Dir.chdir(foo_dir) do
      expect(VHP::InVHPRepo.check_in_vhp_repo).to be true
    end
  end
end
