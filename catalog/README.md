# Catalog

## Structure

To add a catalog, create a directory and create below files in the directory.
- install.sh
- mise config (optional)
- postinstall scripts (under postinstall directory, optional)

### install.sh

This is the file that is executed from Dockerfile.  
Any installation steps can go here.  
Add the below snippets if mise is used to install.  
(`mise install` should be run for each catalog to minimise the retry time in case catalog installation fails)

```sh
#!/bin/bash
set -eo pipefail

script_dir=$(dirname "$0")

if [ -f "$script_dir/<catalog>.toml" ]; then
  cp -- "$script_dir/<catalog>.toml" ~/.config/mise/conf.d/
fi
if ls "$script_dir/<catalog>/postinstall/"* > /dev/null 2>&1; then
  cp -- "$script_dir/<catalog>/postinstall/"* ~/.config/mise/tasks/postinstall/
fi
mise install
```
Code to setup tools installed with mise can also go here, if that is not what should go to postinstall script (see below).

### mise config & postinstall script

Create these files if mise is used to install tools.  
The name of those files should be unique throughout the entire catalog as the files of all the catalogs are copied into the same directory.  
If some setup is required to be run every time the tool version is changed, put them in postinstall script.  
(e.g. generating shell completion, `go install`)
