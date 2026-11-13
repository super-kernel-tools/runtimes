#!/bin/sh
# Publishes the packed runtimes that their release does not offer yet. An offered runtime is never replaced.
#
# Usage: GH_REPO=<owner>/<repository> GH_TOKEN=<token> publish-runtimes.sh <directory>
set -eu

directory=$1

for archive in "$directory"/php-*.tar.gz; do
    name=$(basename "$archive")
    version=${name#php-}
    version=${version%%-*}
    tag="php-$version"

    if ! gh release view "$tag" >/dev/null 2>&1; then
        gh release create "$tag" --title "PHP $version" --notes "Prebuilt SKERNEL runtimes of PHP $version."
    fi

    if gh release view "$tag" --json assets --jq '.assets[].name' | grep -Fxq "$name.sha256"; then
        echo "$name is published already."
        continue
    fi

    # SKERNEL reads the digest file first, so it goes last: a runtime is offered only once its archive is there.
    # An archive without a digest file is left over from an interrupted run and was never offered.
    gh release upload "$tag" "$archive" --clobber
    gh release upload "$tag" "$archive.sha256"
    echo "Published $name."
done
