[![Unit tests](https://github.com/VulnerabilityHistoryProject/shepherd-tools/workflows/Unit%20tests/badge.svg)](https://github.com/VulnerabilityHistoryProject/shepherd-tools/actions)
# VHP SHEPHERD TOOLS

## How to Install
1. git clone this repo
2. run the following command:

```sh
rake install
```

After that, you should have the `vhp` binary on your PATH, and should be able to run `vhp --version` with no issues. Reach out if that's not the case.

# Command Line Interface

You can get CLI documentation by running `vhp` by itself to get the list of commands, and then `vhp help <command>` to find more details about that command.

# Examples

See the CHORES.md file in the `vulnerabilities` repo for up-to-date examples.

# Using on RIT Research Cluster

You'll need to load the following:

```
$ spack load ruby
$ spack load git@2.25
```
