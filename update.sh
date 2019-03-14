#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"

git submodule update --recursive --remote
brew bundle dump --force --file="$DIR/brewfiles/new"
