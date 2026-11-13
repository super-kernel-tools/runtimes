#!/bin/sh
# Lists what decides which runtimes SKERNEL builds, one per line: this repository's commit, the latest SKERNEL
# release, the latest release of every supported PHP branch, and the stable PECL releases of the extensions whose
# version SKERNEL selects. A scheduled run builds only when the list differs from the one published last.
#
# Usage: GH_TOKEN=<token> list-inputs.sh
set -eu

echo "process $(git rev-parse HEAD)"
echo "skernel $(gh api repos/super-kernel-tools/skernel/releases/latest --jq .tag_name)"
curl -fsSL --retry 3 https://www.php.net/releases/active.php | jq -r '.. | objects | .version? // empty' |
    sort -u | sed 's/^/php /'

for extension in redis swoole; do
    curl -fsSL --retry 3 "https://pecl.php.net/rest/r/$extension/allreleases.xml" |
        grep -o '<v>[^<]*</v><s>stable</s>' | sed "s/<v>\([^<]*\)<.*/$extension \1/" | sort -u
done
