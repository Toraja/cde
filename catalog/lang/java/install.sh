#!/bin/bash
set -eo pipefail

# TODO: must be updated to use mise
# XXX not tested
export PATH="$HOME/.asdf/shims:$PATH"
asdf-global-installer.sh java
# taken from https://github.com/halcyon/asdf-java/blob/master/set-java-home.fish
cat << _EOF_ > ${HOME}/.config/fish/conf.d/java.fish
set --local java_path (asdf which java 2>/dev/null)
if test -n "$java_path"
    set --local full_path (builtin realpath "$java_path")

    set --global --export JAVA_HOME (dirname (dirname "$full_path"))
    set --global --export JDK_HOME "$JAVA_HOME"
end
_EOF_

# Maybe it's better to do this manually in a bind mounted directory after image
# is built because it takes really long time to complete.
# Though the document on github does not specify, build fails with `-DskipTests` option.
git clone --depth 1 https://github.com/eclipse/eclipse.jdt.ls.git ${HOME}/tmp/eclipse.jdt.ls
cd ${HOME}/tmp/eclipse.jdt.ls
./mvnw clean verify -DskipTests
