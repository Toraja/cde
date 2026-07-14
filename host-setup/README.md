# Host setup

- Add proxy info to `/etc/environment` if proxy is required.  
  `/etc/environment` is common setting for both root and non-root users. As some playbook tasks require root priviledge, make sure proxy setting is also effective to root user.
  ```
  HTTP_PROXY=<PROXY_HOST_PORT>
  HTTPS_PROXY=<PROXY_HOST_PORT>
  NO_PROXY=localhost,127.0.0.0/8
  http_proxy=<PROXY_HOST_PORT>
  https_proxy=<PROXY_HOST_PORT>
  no_proxy=localhost,127.0.0.0/8
  ```
- Generate a ssh key pair and put the public key on Github
  ```sh
  ssh-keygen -t ed25519 -C 'Toraja@users.noreply.github.com' -f "$HOME/.ssh/<key_file_name>"
  ```
- Copy [ssh config](.ssh/config) from GitHub to your machine.
- Clone this repository  
  This repo is expected to be cloned to `~/cde`. (Later moved to ghq managed directory during `repositories` recipe in justfile)
  ```sh
  git clone git@github.com:Toraja/cde.git ~/cde
  cd ~/cde
  ```
- Copy `.env.example` and modify `.env`.
  ```sh
  cp .env.example .env
  ```
- Make sure `curl` is installed.
- Setup prerequisite stuff.
  ```sh
  host-setup/first-step.sh
  ```
- Run recipes in `justfile`.  
  `repositories` and `ansible` must be run first, then playbook recipes can be run in any order.
  ```sh
  just host-setup/ repositories ansible
  ```
  ```sh
  just host-setup/ playbook::<recipe>
  ```

## WSL
For WSL environment, do the `Setup` and `Configuration` illustrated in [here](https://github.com/Toraja/candyjar/blob/master/windows/wsl/wsl.adoc).
