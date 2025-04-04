# Host setup

- Generate ssh key and put on Github
  ```sh
  ssh-keygen -t ed25519 -C 'Toraja@users.noreply.github.com' -f "$HOME/.ssh/<key_file_name>"
  ```
- Copy `.ssh/config` to your machine.
- Clone this repository
  ```sh
  git clone git@personal.github.com:Toraja/cde.git ~/cde
  ```
- Add your sudo password to `.ansible_become_password` file.
- Make sure `curl` is installed.
- Run `first-step.sh` to setup prerequisite stuff.
- Run recipes in `justfile`.
