module VHP
  module YMLHelper
    # Load YML the way we expect: symbolized names,
    # even if they specified symbols or not
    def load_yml_the_vhp_way(f)
      YAML.load(File.read(f), symbolize_names: true)
    end

    # Expected: a cve_yml hash, key of commits
    # Returns: every commit sha in the fixes hash
    #
    # e.g. when the YML has
    # fixes:
    #   - commit: abc
    #     note:
    #   - commit:
    #     note:
    # extract_shas_from_commitlist(h, :fixes) => ['abc']
    def extract_shas_from_commitlist(h, key)
      unless h.key? key
        warn "ERROR Malformed CVE YML? #{h[:CVE]} should have a `fixes` key. Skipping. Hash: #{h}"
        return []
      end
      begin
        shs = h[key].inject([]) do |memo, fix|
          memo << fix[:commit] unless fix[:commit].to_s.strip.empty?
          memo
        end
      rescue => e
        warn "ERROR extracting YML info for #{h[:CVE]}: #{e.message}"
        return []
      end
    end

  end
end
