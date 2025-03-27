#!/usr/bin/fish

set --local FAIL_EVENT fail
function create_fish_dirs --on-event $FAIL_EVENT
    # `curl` complains SSL error under certain environment (VPN etc).
    # Skip installing fisher in such case and do things which would have done otherwise
    # if plugins were successfully installed. (such as creating directories)
end

curl -fsSL https://git.io/fisher | source
for code in $pipestatus
    if [ $code -gt 0 ]
        emit $FAIL_EVENT
        exit 1
    end
end

fisher install \
    jorgebucaran/fisher \
    decors/fish-colored-man \
    decors/fish-ghq \
    laughedelic/fish_logo \
    markcial/upto \
    joehillen/to-fish \
    edc/bass
or begin
    emit $FAIL_EVENT
    exit 1
end

# change keybind of fish-ghq
sed -i 's/\\\\cg/\\\\er/g' ~/.config/fish/conf.d/ghq_key_bindings.fish
