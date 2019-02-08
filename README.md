# SHEPHERD TOOLS

### How to Install
```sh
gem build shepherd_tools.gemspec
gem install shepherd_tools
```
### Commands:
After installing Shepherd Tools, you can use commands that follow the following format:
```sh
shepherd_tools command [args] <options>
```
#### Migration
Migration has three arguments and one option and follows the following format:
```sh
shepherd_tools migrate regexp insert_text_file position <options>
```
###### ARGS:
1. regexp: This is the regex for a line in the CVE YAMLS.
2. insert_text_file: To insert text into the YAML files, you will need to create a file with the text you wish to insert. This ARG is the path to this file.
3. position: There are three options for this ARG. "before, after, replace". This is where the insert text will be placed relative of the regexp.
###### Options:
-- \-\-validate: Validates the Yamls during the migration. Migration will not stop but offending files will throw warnings.
-- \-\-run: The script generated will be automatically run.
##### Examples:
Initial generation of script:
```sh
shepherd_tools migrate "CVE: CVE-\d{4}-\d+" insert_file.txt after --validate
```
Run generated script:
```sh
ruby migration/migrate_2019_02_04_12_41.rb
```
