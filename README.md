# CDE - Containerised Develop Environment

## Things to do on Host machine
- Generate ssh key and put on Github
  `ssh-keygen -t rsa -b 4096 -C '<description>' -f '/home/<user>/.ssh/<key_file_name>'`
- Create ssh config
  ```sshconfig
  Host github.com
      User <github user>
      IdentityFile <path to key file>
  ```
- Clone this repository and toybox  
	- `mkdir -p ~/workspace/toraja`
  - `git clone git@github.com:Toraja/cde.git ~/workspace/toraja/cde`
	- `git clone git@github.com:Toraja/toybox.git ~/workspace/toraja/toybox`
  - `ln -s ~/workspace/toraja/toybox ~/toybox`
- Install `make` and run `make` in `host-setup` directory.
- Run `cp .env.example .env` and set appropriate values.

### WSL
- Do the setup and configuration illustrated
  [here](https://github.com/Toraja/toybox/blob/master/windows/wsl/wsl.md)

## Start Container
Containers are separated by language.  
Each language requires `base` image have been built. Run `make build c=base` to
build the docker image.
Run `make enter c=<cde>` to start and get inside the container.

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

## Localisation
You can extend images by utilising `localise` directory.
Inside the `localise` directory, you should at least have:
```
localise
├── Makefile
├── docker-compose.yml
└── ctx
    └── Dockerfile
```

Localised `Makefile` is included in the main `Makefile` automatically.
You can also `git clone` repository if the directory structure mathces it.
