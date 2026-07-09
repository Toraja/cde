# Catalog

## Add a catalog

To add a catalog, run:

```sh
just add <catalog path> [mise tools...]
```

This will create a new directory under `catalog` with the name of the catalog with the following files:
- install.sh
- mise config (optional)
- postinstall scripts (under postinstall directory, optional)

### install.sh

This is the file that is executed from Dockerfile.  
Any installation steps can go here.  
Code to setup tools installed with mise can also go here, if that is not what should go to postinstall script (see below).

### mise config & postinstall script

Create these files if mise is used to install tools.  
The name of those files should be unique throughout the entire catalog as the files of all the catalogs are copied into the same directory.  
If some setup is required to be run every time the tool version is changed, put them in postinstall script.  
(e.g. generating shell completion, `go install`)
