# TOOLS:

#### Migration
1. Navigate to the *shepherd-tools* directory
2. Open command line in this folder
3. Run the script `migrate_gen.rb` with three args in:
    3.1. The directory path where the cves are located e.g. ../cves
    3.2. The regex for the line above where the text will be inserted. Make sure the regex is within quotes.  e.g. "CVE: CVE-\d{4}-\d+"
    3.3. The file path of the text to be inserted. e.g. migration/inputs/input20190204.txt
4. A new migration script will be generated in the `migration` folder
5. Run the generated script, named after the date and time of generation

##### Examples:
Initial generation of script:
```sh
ruby scripts/migrate_gen.rb cves "CVE: CVE-\d{4}-\d+" migration/inputs/input20190204.txt
```
Run generated script:
```sh
ruby migration/migrate_2019_02_04_12_41.rb
```
