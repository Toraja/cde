# Host setup

- Generate ssh key and put on Github
  ```sh
  ssh-keygen -t ed25519 -C 'Toraja@users.noreply.github.com' -f "$HOME/.ssh/<key_file_name>"
  ```
- Copy `.ssh` directory under `host-setup`
  ```sh
  cp .ssh ~
  ```
- Clone this repository
  ```sh
  git clone git@personal.github.com:Toraja/cde.git ~/cde
  ```
- Install `make` and run `make` in `host-setup` directory.
  ```sh
  apt update && apt install make
  ```
  ```sh
  make
  ```
- Copy `.env` and set appropriate values.
  ```sh
  cp .env.example .env
  ```
