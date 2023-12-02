#!/usr/bin/fish

set --local FAIL_EVENT fail
function create_fish_dirs --on-event $FAIL_EVENT
    # `curl` complains SSL error under certain environment (VPN etc).
    # Skip installing fisher in such case and create directories otherwise
    # created by installing plugins as these must exist for later commands.
    mkdir -p ~/.config/fish/completions ~/.config/fish/conf.d
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
    evanlucas/fish-kubectl-completions \
    edc/bass
or begin
    emit $FAIL_EVENT
    exit 1
end

# change keybind of fish-ghq
sed -i 's/\\\\cg/\\\\er/g' ~/.config/fish/conf.d/ghq_key_bindings.fish
