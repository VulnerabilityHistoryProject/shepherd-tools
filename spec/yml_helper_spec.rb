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

  context :extract_shas_from_commitlist do

    it 'loads typical commits' do
      h = {
        fixes: [
          { commit: 'abc', note: 'not seen'},
          { commit: 'def', note: 'not seen'},
        ]
      }
      expect(extract_shas_from_commitlist(h, :fixes)).to eq(['abc', 'def'])
    end

    it 'loads typical commits ignoring blanks' do
      h = {
        fixes: [
          { commit: 'abc', note: 'not seen'},
          { commit: '', note: 'not seen'},
          { commit: nil, note: 'not seen'},
          { commit: '    ', note: 'not seen'},
        ]
      }
      expect(extract_shas_from_commitlist(h, :fixes)).to eq(['abc'])
    end

    it 'works fine on an empty array' do
      h = { fixes: [] }
      expect(extract_shas_from_commitlist(h, :fixes)).to eq([])
    end

    it 'warns and continues on with malformed' do
      h = { fixes: nil }
      expect(self).to receive(:warn).with(/ERROR extracting YML/)
      expect(extract_shas_from_commitlist(h, :fixes)).to eq([])
    end

  end

end
