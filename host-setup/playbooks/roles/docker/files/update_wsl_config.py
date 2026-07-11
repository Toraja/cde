import configparser
import sys

config_file = "/etc/wsl.conf"
section = "boot"
option = "systemd"

config = configparser.ConfigParser()
config.read(config_file)

if config.getboolean(section, option, fallback=False):
    # Config is in the desired state
    sys.exit(1)

if not config.has_section(section):
    config[section] = {}

config[section][option] = "true"

with open(config_file, "w") as configfile:
    config.write(configfile)

sys.exit(0)
