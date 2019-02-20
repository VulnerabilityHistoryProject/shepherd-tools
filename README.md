# SHEPHERD TOOLS

### How to Install
1. git clone this repo
2. run the following command:
```sh
rake install:gem
```

### Commands
After installing Shepherd Tools, you can use commands that follow the following formats:
```sh
vhp command [args] <options>
vhp command <options>
vhp command subcommand <options>
```
#### Migration
Migration has three arguments and five option and follows the following format:
```sh
vhp migrate regexp insert_text_file position <options>
```

###### ARGS
1. regexp: This is the regex for a common line in the files.
2. insert_text_file: To insert text into a directory files, you will need to create a file with the text you wish to insert. This ARG is the path to this file.
3. position: There are three options for this ARG. "before, after, replace". This is where the insert text will be placed relative of the regexp.

###### Options
* \-\-voff: Validation of migrated Yamls is on by default. Use this option if not migrating ymls or it annoys you.
* \-\-run: The script generated will be automatically run.
* \-\-dir DIR:  This option will set the migration directory. Default: cves dir
* \-\-type TYPE:  Specifies filename extension. Default: .yml
* \-\-end REGEX: This option is only for when replacing text. If you would like to replace multiple lines, use this option and give it the regex of the line you would like to replace until. This line will not be replaced, but all lines above it will be.

###### Examples
Initial generation of script:
```sh
vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt after
```
You can run your generated script like this:
```sh
ruby migration/migrate_2019_02_04_12_41.rb
```
Alternatively, you can generate and run in one command:
```sh
vhp migrate "CVE: CVE-\d{4}-\d+" insert_file.txt after --run
```
Replace multiple lines example:
```sh
vhp migrate "CVE: CVE" insert_file.txt replace --end "security_bulletin" --run
```

###### Note
In insertion files, do not bother adding new lines as padding. New lines are adding automatically according to the insertion method.


#### Validation
Validation of YAMLs follows the following format:
```sh
vhp validate <options>
```

###### Options
* \-\-cves DIR: Sets the CVE directory. Default: cves

###### Examples
```sh
vhp validate
vhp validate --cves ../mydir/cves
```


#### List
The list command follows the following format:
```sh
vhp list subcommand <options
```

###### Subcommands
* curated: Lists all curated cves
* uncurated: Lists all uncurated cves
* fixes: Lists all fix shas

###### Options
* \-\-cves DIR: Sets the CVE directory. Default: cves

###### Examples
```sh
vhp list curated
vhp list uncurated --cves ../cves
vhp list fixes
```


#### Find
The find command follows the following format:
```sh
vhp find subcommand <options>
```

###### Subcommands
* publicvulns: Find all vulnerable fines from the gitlog

###### Options
* \-\-repo DIR: Sets the repository directory. Default: current working directory
* \-\-cves DIR: Sets the CVE directory. Default: cves
* \-\-period PERIOD: Sets the time period for the test. Either "6_month" or "all_time"
* \-\-output DIR: Sets the directory where the CSV will be saved.

###### Examples
```sh
vhp find curated
vhp find uncurated --dir ../mydir
vhp find publicvulns --repo struts --period 6_month
vhp find publicvulns --repo tomcat
```


#### Load commits
Loading the git log JSON with commit data follows the following format
```sh
vhp loadcommits subcommand <options>
```

###### Subcommands
* mentioned: All commits mentioned in a CVE YAML
###### Options
* --json JSON: Sets the gitlog_json location. Default: commits/gitlog.json
* --repo DIR: Sets the repository directory. Default: current working directory
* --cves DIR: Sets the CVE directory. Default: cves
* --skip_existing: Skips shas that are already in the JSON.

###### Examples
```sh
vhp loadcommits mentioned --repo struts
vhp loadcommits mentioned --json ../../data/commits/gitlog.json --skip_existing
```


#### Report - CURRENTLY NOT WORKING
Generating reports follows the following format
```sh
vhp report timeperiod <options>
```

###### Time periods
* weekly: Time period of one week

###### Options
* \-\-save DIR: By default, reports are saved in commits/weeklies. Manually set the directory with this option.
* \-\-repo DIR: By default, the working directory is assumed to be the repo directory. Manually set the directory with this option.
* \-\-cve DIR: By default, the cve directory is assumed to be "/cves". Manually set the directory with this option.

###### Examples
```sh
vhp report weekly --save reports, --repo ../src
```
