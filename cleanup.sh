#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

source "$HOME/.cfgrc"
source util_fns.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"
EDITOR="$(get_editor)"

function main {
  cleanup_homebrew_packages
  find_broken_symlinks
  find_global_pip_packages
  find_global_npm_packages
}

function cleanup_homebrew_packages {
  step "Old Homebrew packages are cleaned up"
  brew cleanup
  echo "brew bundle cleanup --global"
  brew bundle cleanup --global
}

function find_broken_symlinks {
  step "No broken symlinks"
  find "$HOME" -path "$HOME/Library" -prune -o -path "$HOME/.Trash" -prune -o -type l ! -exec test -e {} \; -print
  if [[ $BIN_HOME/ != $HOME/* ]]; then
    find "$BIN_HOME" -type l ! -exec test -e {} \; -print
  fi
  echo "Done."
}

function find_global_pip_packages {
  step "No global pip packages"
  if [ $(pip list --format=freeze | grep -v "pip\|setuptools\|wheel" | wc -l) -gt 0 ]; then
    echo "The following packages are installed globally via pip:"
    pip list --format=freeze | grep -v "pip\|setuptools\|wheel"
    echo "Remove these packages and install them locally with pipenv instead."
    exit 1
  else
    echo "No pip packages found."
  fi
}

function find_global_npm_packages {
  step "No global npm packages"
  find "$HOME/.config/nvm" -type d -depth 1 | while read node_dir; do
    all_packages=$(eval $node_dir/bin/node $node_dir/bin/npm ls -gp --depth=0)
    filtered_packages=$(echo "$all_packages" | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}')
    if [ $(echo "$filtered_packages" | grep -v '^\s*$' | wc -c) -gt 0 ]; then
      echo "The following packages are installed globally via npm:"
      echo "$filtered_packages"
      echo "Remove these packages and install them locally instead."
      exit 1
    else
      echo "No npm packages found for version at $node_dir"
    fi
  done
}

main
