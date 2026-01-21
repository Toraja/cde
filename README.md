# CDE - Containerised Develop Environment

## Setup
### Things to do on Host machine
Refer to [Host setup README](./host-setup/README.md)

#### WSL
- Do the setup and configuration illustrated in
  [here](https://github.com/Toraja/candyjar/blob/master/windows/wsl/wsl.adoc)

### Prepare .env
Run the below command and and modify `.env`.
```sh
cp .env.example .env
```

### Adding environments
1. `just new-env <bundle> <project>`
1. If you are adding a new bundle and:
    - Need common setup (base image) for your projects:
        - Modify `Dockerfile` in the base env
    - Otherwise:
        - Edit `docker-bake.hcl` to:
            - Remove `base` section
            - Change default value of `PROJECT_BASE_IMAGE` to `target:root`
        - Delete `env/<bundle>/base` directory
1. Modify `Dockerfile` in the env

#### Dockerfile
By default, `catalog` directory is given as addtional build context.  
Pick things you need from catalog and run the installers.

#### Use external environments
Environments in the `env` directory can be symlinks that point to other directories.  
This is conveinent if:
- You want to store environments in git repository
- Environments somehow need to be stored in another directory

The symlink targets must have the same structure as `skeleton/bundle` directory.  
The easiest way to create a new external environment is to:
- Add a new environment as usual
- Move the bundle directory to somewhere else
- Create a symlink pointing to the directory in the `env` directory

## Usage
To build image or start container, run the command below.
```
just <recipe> env/<path to project>
```
To view the available recipes, simply run `just`.

## Development notes

### Symlink

If a symlink target does not exist, the symlink seems to be treated like a normal file.  
So make sure that the target exists prior to container runtime.

- If a symlink points to a file/directory in a volume, the target should be created during image build.
- For symlinks pointing to a file/directory in a volume mount, creating during image build is not possible.  
    Avoid using such symlinks unless the files/directories pointed by symlinks are supposed to exist on the host.  
    Use external volume instead.
    - 🆗: neovim configs (neovim is setup on host side as well)
    - 👎: taskwarrior's data location directory (To do so requires host-setup or manually create one)
        - However, to simplify the configuration, those directories are currently created in host-setup.

