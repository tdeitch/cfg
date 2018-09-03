#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"

function prompt {
  read -p "Continue [y/N]? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    true
  else
    false
  fi
}

brew bundle cleanup --global
if prompt; then
  brew bundle cleanup --global --force
fi

echo
echo "pip2 would uninstall:"
pip2 freeze
if prompt; then
  pip2 freeze | xargs pip2 uninstall -y
fi

echo
echo "pip3 would uninstall:"
pip3 freeze
if prompt; then
  pip3 freeze | xargs pip3 uninstall -y
fi

echo
echo "npm would uninstall:"
npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}'
if prompt; then
  npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm
fi

echo
echo "gem would uninstall:"
gem list
if prompt; then
  gem uninstall --all
fi
