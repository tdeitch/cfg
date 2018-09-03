#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"

git submodule update --recursive --remote

brew bundle dump --force --global
sort -o "dotfiles/.Brewfile" "dotfiles/.Brewfile"

cd "$DIR/packages"
pip2 freeze | sed 's/==.*//' | sort > pip2-requirements.txt
pip3 freeze | sed 's/==.*//' | sort > pip3-requirements.txt
npm list -g --depth=0 --json | jq --raw-output '.[] | keys | .[]' | sort > npm-packages.txt
gem list | cut -d' ' -f 1 | sort > gems.txt
