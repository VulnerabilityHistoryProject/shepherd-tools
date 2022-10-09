module VHP
  module YMLHelper
    # Load YML the way we expect: symbolized names,
    # even if they specified symbols or not
    def load_yml_the_vhp_way(f)
      YAML.load(File.read(f), symbolize_names: true)
    end

    def write_yml_the_vhp_way(yml, outfile)
      File.open(outfile, 'w+') do |file|
        yml_txt = yml.to_yaml[4..-1] # strip off ---\n
        stripped_yml = ""
        yml_txt.each_line do |line|
          # strip trailing whitespace, replace :foo: with foo:
          stripped_yml += "#{line.gsub(/:(\w+:)/, '\1').rstrip}\n"
        end
        file.write(stripped_yml)
      end
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
