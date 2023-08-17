# CDE - Containerised Develop Environment

## Setup
### Things to do on Host machine
Refer to [Host setup README](./host-setup/README.md)

#### WSL
- Do the setup and configuration illustrated in
  [here](https://github.com/Toraja/toybox/blob/master/windows/wsl/wsl.md)

### Add environments
Refer to [Skeleton README](./skeleton/README.adoc)

## Usage
To build image or start container, run the command below.
```
just <recipe> env/<path to project>
```
To view the available recipes, simply run `just`.
