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
- Install `just` and run recipes.
  ```sh
  PATH="$HOME/.local/bin:$PATH"
  mkdir -p $HOME/.local/bin
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to $HOME/.local/bin
  cd host-setup
  just prerequisite
  # just <recipes>
  ```
