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
<<<<<<< HEAD
Migration has three arguments and one option and follows the following format:
```sh
shepherd_tools migrate regexp insert_text_file position <options>
```
###### ARGS:
1. regexp: This is the regex for a line in the CVE YAMLS.
2. insert_text_file: To insert text into the YAML files, you will need to create a file with the text you wish to insert. This ARG is the path to this file.
3. position: There are three options for this ARG. "before, after, replace". This is where the insert text will be placed relative of the regexp.
###### Options:
1. \-\-validate: Validates the Yamls during the migration. Migration will not stop but offending files will throw warnings.
=======
1. Navigate to the *shepherd-tools* directory
2. Open command line in this folder
3. Run the script `migrate_gen.rb` with four args in:

    3.1. The directory path where the cves are located e.g. ../cves

    3.2. The regex for the line above where the text will be inserted. Make sure the regex is within quotes AND UNIQUE to the line. If the  line is not unique, the text may be inserted multiple times.  e.g. "CVE: CVE-\d{4}-\d+"

    3.3. The file path of the text to be inserted. e.g. migration/inputs/input20190204.txt

    3.4. The position you wish to insert the text relative to the regex. The options are `after`, `before`, and `replace`.
4. A new migration script will be generated in the `migration` folder
5. Run the generated script, named after the date and time of generation
>>>>>>> 0cbb663b2a2bfefe2c09fc49a63a9b012cca74e9

##### Examples:
Initial generation of script:
```sh
<<<<<<< HEAD
shepherd_tools migrate "CVE: CVE-\d{4}-\d+" insert_file.txt after --validate
=======
ruby scripts/migrate_gen.rb cves "CVE: CVE-\d{4}-\d+" migration/inputs/input20190204.txt after
>>>>>>> 0cbb663b2a2bfefe2c09fc49a63a9b012cca74e9
```
Run generated script:
```sh
ruby migration/migrate_2019_02_04_12_41.rb
```
