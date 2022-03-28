#!/usr/bin/fish
# XXX Somehow this does not create ~/.asdf/shims directory and installed plugins cannot be found

type -q asdf; or begin
    echo (set_color red)asdf is not installed(set_color normal)
    exit 1
end

test (count $argv) -eq 0; and begin
    set --local help (basename (status --current-filename))" <plugin name[:version]> [plugin name[:version]...]"
    echo (set_color red)Argument is required.(set_color normal)
    echo $help
    exit 1
end

for plugin in $argv
    set --local pluginfo (string split ':' $plugin)
    set --local plugin_name $pluginfo[1]
    set --local plugin_ver (test (count $pluginfo) -gt 1; and echo $pluginfo[2]; or echo latest)

    echo asdf plugin-add $plugin_name
    echo asdf install $plugin_name $plugin_ver
    echo asdf global $plugin_name $plugin_ver
end
