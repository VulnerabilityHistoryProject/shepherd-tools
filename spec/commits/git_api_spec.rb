require_relative '../helper'

describe VHP::GitAPI do

  around(:each) do |example|
    Dir.chdir(foo_dir) do
      # silently do
        example.run
      # end
    end
  end

  context :save do
    it 'saves a simple SHA' do
      api = VHP::GitAPI.new(this_repo)

      sha = 'testdata-check-commit' # this needs to be a tag for GitHub actions
      expect(api.save(sha, true)).to eq({
        author: 'Andy Meneely',
        email: 'andy@se.rit.edu',
        date: Time.parse('2020-06-06 16:28:13.000000000 -0400'),
        message: "we now warn if we're not in a VHP repo!!",
        insertions: 2, deletions: 277,
        filepaths: {
          "Rakefile" => { deletions: 14, insertions: 1 },
          "bin/vhp" => { deletions: 1, insertions: 1 },
          "foo-vulnerabilities/README.md" => { deletions: 3, insertions: 0 },
          "foo-vulnerabilities/commits/gitlog.json" => { deletions: 1, insertions: 0 },
          "foo-vulnerabilities/cves/CVE-1984-0519.yml" => { deletions: 206, insertions: 0 },
          "foo-vulnerabilities/project.yml" => { deletions: 14, insertions: 0 },
          "lib/vhp/in_vhp_repo.rb" => { deletions: 17, insertions: 0 },
          "lib/vhp/paths.rb" => { deletions: 4, insertions: 0 },
          "test/test_paths.rb" => { deletions: 17, insertions: 0 }
         }
      })
    end

    it 'saves a rename' do
      api = VHP::GitAPI.new(this_repo)
      sha = '970606200911b3782e9fe5950f4b93ba2b812293' # testdata-rename
      expect(api.save(sha, true)).to eq({
        :author=>"Andy Meneely",
        :email=>"andy@se.rit.edu",
        :date=>Time.parse('2020-06-08 00:26:42 -0400'),
        :message=>"redid the migration process\n\nCloses #8",
        :insertions=>214,
        :deletions=>410,
        :filepaths=> {
          "foo-vulnerabilities/cves/CVE-1984-0519.yml" => {:insertions=>49, :deletions=>32},
          "foo-vulnerabilities/migrations/2020_06_08_00_14_35_foo_bar.rb" => {:insertions => 0, :deletions => 72},
          "foo-vulnerabilities/skeletons/cve.yml" => {:insertions => 0, :deletions => 189},
          "lib/vhp/commands/CLI.rb" => {:insertions => 8, :deletions => 6},
          "lib/vhp/migrate/migrate_gen.rb" => {:insertions => 86, :deletions => 0},
          "lib/vhp/migrate/migrate_template.rb.erb" => {:insertions => 8, :deletions => 0},
          "lib/vhp/migrate/migration.rb" => {:insertions => 63, :deletions => 0},
          "lib/vhp/migrate/migration_generator.rb" => {:insertions => 0, :deletions => 13},
          "lib/vhp/migrate/migration_template.rb.txt" => {:insertions => 0, :deletions => 72},
          "lib/vhp/paths.rb" => {:insertions => 0, :deletions => 12},
          "spec/paths_spec.rb" => {:insertions => 0, :deletions => 14}
        }
      })
    end
  end

  context :save_mega do
    it 'saves a mega commit with no file info' do
      api = VHP::GitAPI.new(this_repo)
      sha = '8fc950b705e24fd6adc238511f3ac882a9b12b20' # testdata-megacommit
      expect(api.save_mega(sha, "curator note!", true)).to eq({
        :author=>"mdt8740",
        :email=>"mattthyng@gmail.com",
        :date=>Time.parse('2019-02-08 10:54:57 -0500'),
        :message=> "CURATOR NOTE\n  This is a very large commit.\n  The curators of VHP have decided not to show all of the file information for brevity.\n  Specifically, the curators stated:\n    curator note!\n\nORIGINAL MESSAGE: Merge branch 'master' of https://github.com/VulnerabilityHistoryProject/shepherd-tools\n",
        :filepaths=>{}})
    end
  end

  context :get_files_in_commit do
    it 'gets a list of files from a simple commit' do
      api = VHP::GitAPI.new(this_repo)
      expect(api.get_files_in_commit('testdata-driveby')).to eq([
        'lib/vhp/report/weekly_report.rb'
      ])
    end

    it 'lists boths files on a rename' do
      api = VHP::GitAPI.new(this_repo)
      expect(api.get_files_in_commit('testdata-rename-simple')).to eq([
        'spec/helper.rb',
        'spec/helper_renamed.rb',
      ])
    end
  end

  context :get_files_from_shas do
    it 'gets a list of files from a few commits' do
      api = VHP::GitAPI.new(this_repo)
      commits = ['testdata-driveby', 'testdata-rename-simple']
      expect(api.get_files_from_shas(commits)).to eq([
        "lib/vhp/report/weekly_report.rb",
        "spec/helper.rb",
        "spec/helper_renamed.rb"
      ])
    end

    it 'uniqs properly' do
      api = VHP::GitAPI.new(this_repo)
      commits = ['testdata-driveby', 'testdata-driveby']
      expect(api.get_files_from_shas(commits)).to eq([
        "lib/vhp/report/weekly_report.rb"
      ])
    end
  end


end
