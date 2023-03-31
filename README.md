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

## Volume Policy
- Bind mount if:
  - Need to sync between container and host machine (such as date/time and
    docker socket)
  - Files need to be modified on the host side (such as files in this repository)
  - Files are unrecoverable (such as workspace)
- External volume if:
  - Need to share between containers.
  - Condition for bind mount does not apply but want to avoid accidental
    deletion by `docker-compose down -v`.  
    Note that it is still prone to `docker volume prune` if there is no
    container that is using the volume, so labels are added to those volumes and
    `pruneFilter` is set in `config.json`.
- Volume if:
  - Need to persist across container life cycle.
