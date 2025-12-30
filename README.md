# CDE - Containerised Develop Environment

## Setup
### Things to do on Host machine
Refer to [Host setup README](./host-setup/README.md)

#### WSL
- Do the setup and configuration illustrated in
  [here](https://github.com/Toraja/candyjar/blob/master/windows/wsl/wsl.adoc)

### Add environments
Refer to [Skeleton README](./skeleton/README.adoc)

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

