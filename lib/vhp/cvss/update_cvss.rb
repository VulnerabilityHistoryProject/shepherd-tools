require_relative '../utils/helper.rb'
require 'httparty'

module ShepherdTools
  class UpdateCVSS
    def initialize(options)
      @dir = ShepherdTools.handle_cves(options)
    end

    def update_cvss
      base_url = "https://nvd.nist.gov/vuln/detail/"
      Dir.foreach(@dir) do |filename|
        cve = filename[0..-5]
        res = HTTParty.get(base_url + cve)
        cvss = ""
        if res.body.match(/(AV:.\/AC:.\/PR:.\/UI:.\/S:.\/C:.\/I:.\/A:.)/)
          cvss = res.body.match(/(AV:.\/AC:.\/PR:.\/UI:.\/S:.\/C:.\/I:.\/A:.)/)
        else
          cvss = res.body.match(/(AV:.\/AC:.\/Au:.\/C:.\/I:.\/A:.)/)
        end

        if cvss
          puts cve
          lines = File.readlines(@dir + '/' + filename)
          (0..lines.length).each do |i|
            if lines[i][0..3] == "CWE:"
              if lines[i+1][0..4] != "CVSS:"
                lines.insert(i+1, "CVSS: " + cvss[0] + "\n")
              end
              break
            end
          end
          File.open(@dir + '/' + filename, "w+") do |f|
            lines.each { |element| f.puts(element) }
          end
        end
      end
    end
    
  end
end
