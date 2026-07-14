# Host setup

- Generate ssh key and put on Github
  ```sh
  ssh-keygen -t ed25519 -C 'Toraja@users.noreply.github.com' -f "$HOME/.ssh/<key_file_name>"
  ```
- Copy `.ssh/config` to your machine.
- Clone this repository
  ```sh
  git clone git@github.com:Toraja/cde.git ~/cde
  ```
- Make sure `curl` is installed.
- Run `first-step.sh` to setup prerequisite stuff.
- Run recipes in `justfile`.
  - If proxy is required, add proxy info to `/etc/environment`.  
    `/etc/environment` is commont setting for both root and non-root users. As some playbook tasks require root priviledge, make sure proxy setting is also effective to root user.
    ```
    HTTP_PROXY=<PROXY_HOST_PORT>
    HTTPS_PROXY=<PROXY_HOST_PORT>
    NO_PROXY=localhost,127.0.0.0/8
    http_proxy=<PROXY_HOST_PORT>
    https_proxy=<PROXY_HOST_PORT>
    no_proxy=localhost,127.0.0.0/8
    ```
