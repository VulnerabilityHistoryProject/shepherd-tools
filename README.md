# SHEPHERD TOOLS
### How to Install
1. Navigate to your VHP repo
2. git clone this repo
3. run the following commands:
```sh
gem build vhp.gemspec
gem install vhp
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
* \-\-dir DIR: By default, migrate will automatically locate your "cves/" directory. This option will set the migration directory.
* \-\-type TYPE: By default, migrate will touch .yml files. This options allows you to specify your own filename extension.
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
* \-\-dir DIR: By default, validate will automatically locate your "cves/" directory. This option will set the migration directory.
###### Examples
```sh
vhp validate
vhp validate --dir ../mydir
```
#### Find
The find command follows the following format:
```sh
vhp find subcommand <options>
```
###### Subcommands
* curated: Find all curated CVE YAMLs.
* uncurated: Find all uncurated CVE YAMLs.
###### Options
* \-\-dir DIR: By default, find will automatically locate your "cves/" directory. This option will set the migration directory.
###### Examples
```sh
vhp find curated
vhp find uncurated --dir ../mydir
```

#### Report
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
