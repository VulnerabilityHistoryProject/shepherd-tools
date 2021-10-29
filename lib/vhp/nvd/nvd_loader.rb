require_relative '../paths'
require_relative '../yml_helper'
require 'httparty'

module VHP
  class NVDLoader
    include Paths
    include YMLHelper

    def run
      base_url = "https://services.nvd.nist.gov/rest/json/cve/1.0/"
      errors = []
      cve_ymls.each do |filename|
        begin
          cve = File.basename(filename, '.yml')
          r = HTTParty.get(base_url + cve).parsed_response
          sleep 0.25
          cvss = r.dig("result",
                      "CVE_Items",
                      0,
                      "impact",
                      "baseMetricV2",
                      "cvssV2",
                      "vectorString").to_s
          published = r.dig("result",
                      "CVE_Items",
                      0,
                      "publishedDate")
          cvss2_regex = %r{^AV:./AC:./Au:./C:./I:./A:.$}
          cvss3_regex = %r{^AV:./AC:./PR:./UI:./S:./C:./I:./A:.$}

          if cvss3_regex.match?(cvss) || cvss2_regex.match?(cvss)
            yml_string = File.open(filename, 'r') { |f| f.read }
            # default to announced == published until curators correct it
            yml_string = yml_string.gsub(/announced_date:\s*\r?\n/, "announced_date: #{published}\n")
            yml_string = yml_string.gsub(/published_date:\s*\r?\n/, "published_date: #{published}\n")
            yml_string += "\nCVSS: #{cvss}\n"
            File.open(filename, 'w') do |f|
              f.write yml_string
            end
            print '.'
          else
            errors <<  "Could not find CVSS string for #{filename}, cvss string: #{cvss}"
          end
        rescue => e
          errors << "Exception on #{filename}: #{e.message}"
        end
      end
      errors.each { |e| warn e }
    end

  end
end