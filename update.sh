#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"

git submodule update --recursive --remote

cd "$DIR/brewfiles"
tmp_dumpfile=$(mktemp)
tmp_oldfile=$(mktemp)
tmp_newfile=$(mktemp)
brew bundle dump --force --file="$tmp_dumpfile"
cat * > "$tmp_oldfile"
sort -o "$tmp_dumpfile" "$tmp_dumpfile"
sort -o "$tmp_oldfile" "$tmp_oldfile"
comm -23 "$tmp_dumpfile" "$tmp_oldfile" > "$tmp_newfile"

tmp_tapfile=$(mktemp)
tmp_pkgfile=$(mktemp)
grep '^tap' "$tmp_newfile" > "$tmp_tapfile"
grep -v '^tap' "$tmp_newfile" > "$tmp_pkgfile"
sort -o "$tmp_tapfile" "$tmp_tapfile"
sort -o "$tmp_pkgfile" "$tmp_pkgfile"
cat "$tmp_tapfile" "$tmp_pkgfile" > new

cd "$DIR/packages"
pip2 freeze | sed 's/==.*//' | sort > pip2-requirements.txt
pip3 freeze | sed 's/==.*//' | sort > pip3-requirements.txt
npm list -g --depth=0 --json | jq --raw-output '.[] | keys | .[]' | sort > npm-packages.txt
gem list | cut -d' ' -f 1 | sort > gems.txt
