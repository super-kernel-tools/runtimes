#!/bin/sh
# Builds every runtime that this repository publishes into the SKERNEL home, with the given SKERNEL binary.
#
# Usage: SKERNEL_HOME=<directory> build-runtimes.sh <skernel-binary>
set -eu

skernel=$1
: "${SKERNEL_HOME:?Set SKERNEL_HOME to the directory that receives the runtimes.}"
work=$(mktemp -d)

# SKERNEL runs its own Composer, whose PHP is one of the published runtimes, only when it finds no working Composer:
# a stand-in that fails comes first in PATH, and an empty home hides the usual locations of a user's Composer.
mkdir "$work/shim" "$work/home"
printf '#!/bin/sh\nexit 1\n' >"$work/shim/composer"
chmod +x "$work/shim/composer"
HOME="$work/home" PATH="$work/shim:$PATH" "$skernel" new "$work/app"

cp -R "$work/app" "$work/app-redis"
composer require super-kernel/redis --working-dir="$work/app-redis" --no-interaction --no-progress \
    --ignore-platform-reqs

# build needs the runtime with the development requirements, and package the one without them.
for app in app app-redis; do
    printf '{"package": {"output": "%s"}}\n' "$work/$app-binary" >"$work/$app/skernel.json"
    "$skernel" build -d "$work/$app"
    "$skernel" package -d "$work/$app"
    env -i "$work/$app-binary" list >/dev/null
    echo "Built the runtimes of $app."
done
