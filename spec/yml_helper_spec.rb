require_relative 'helper'

describe VHP::YMLHelper do
  include VHP::YMLHelper

  context :load_yml_the_vhp_way do
    it 'converts string key names to symbols' do
      h = load_yml_the_vhp_way(cve_1984_0519_file)
      expect(h[:CVE]).to eq("CVE-1984-0519")
    end

    it 'converts recursively' do
      h = load_yml_the_vhp_way(cve_1984_0519_file)
      expect(h[:fixes][0][:note]).to eq("Tagged as testdata-driveby")
    end
  end

end
