require_relative '../paths'
require_relative '../yml_helper'

require 'mechanize'

class PullLatestCVEs
  def tomcat_security_pages
    %w(
      http://tomcat.apache.org/security-9.html
      http://tomcat.apache.org/security-8.html
      http://tomcat.apache.org/security-7.html
      http://tomcat.apache.org/security-6.html
      http://tomcat.apache.org/security-5.html
      http://tomcat.apache.org/security-4.html
      http://tomcat.apache.org/security-3.html
    )
  end

  def is_cve?(link)
    link.href.include? "cve.mitre.org"
  end

  def is_svn?(link)
    link.href.include? "svn.apache.org"
  end

  def get_cve(link)
    link.href.upcase.match( /(?<cvekey>CVE-[\-\d]+)/ )[:cvekey]
  end

  def get_svn_commit(link)
    link.href.upcase.match(/(?<svnid>\d+)/)[:svnid]
  end

  def crawl(url)
    puts "Crawling #{url}"
    cves = {}
    Mechanize.new.get(url) do |page|
      cur_cve = 'REPLACEME'
      page.links.each do | link |
        if is_cve?(link)
          cur_cve = get_cve(link)
          cves[cur_cve] = []
        else
          if is_svn?(link)
            cves[cur_cve] << get_svn_commit(link)
          end
        end
      end
    end
    return cves
  end

  def fix_ymlstr(cve, fixes)
    ymlstr = fixes.inject("") do |str, fix|
      git_sha = svn_id_to_git_sha(fix)
      if git_sha.empty?
        puts "WARN: git sha for svn r#{fix} not found in any repo for #{cve}"
        ''
      else
        str +
          "   - commit: #{git_sha}\n" +
          "     note: SVN rev #{fix}, from the Tomcat website.\n"
      end
    end
    return "fixes:\n" + ymlstr + "   - commit:\n     note:\n"
  end

  def save(cves)
    cves.each do |cve, fixes|
      next if cve_yaml_exists?(cve)
      ymlstr = cve_skeleton_yml.sub(fix_skeleton, fix_ymlstr(cve, fixes))
                               .sub("CVE:\n", "CVE: #{cve}\n")
      File.open(as_filename(cve), 'w+') { |f| f.write(ymlstr) }
      puts "Saved #{as_filename(cve)}"
    end
  end

  def run
    cves = {}
    tomcat_security_pages.each do |url|
      cves.merge! crawl(url) do |k, v1, v2|
         # CVEs can be on multiple pages, so merge the fix lists
        (v1 + v2).uniq
      end
    end
    save(cves)
  end

end