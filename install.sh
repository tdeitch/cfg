#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

source util_fns.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"
EDITOR="$(get_editor)"

function main {
  check_os "Linux"
  copy_templates
  set_shell_to_fish
  install_fisherman_plugins
  link_fish_settings
  link_dotfiles
  link_bin_files
}

function copy_templates {
  step "Templates are present"
  cd "$DIR/templates"
  templates=$(find . -type f | sed "s|^\./||")
  for template in $templates; do
    if [ -e "$HOME/$template" ]; then
      echo "$HOME/$template already exists"
    elif [ "$(basename "$template")" == ".keep" ]; then
      mkdir -p "$(dirname "$HOME/$template")"
    else
      mkdir -p "$(dirname "$HOME/$template")"
      cp "$template" "$HOME/$template"
    fi
  done
}

function set_shell_to_fish {
  step "Fish is set as the login shell"
  echo "Current login shell: $SHELL"
  if [[ ! "$SHELL" =~ "fish" ]]; then
    sudo chsh -s "$(which fish)" $USER
  fi
}

function install_fisherman_plugins {
  step "Fisherman plug-ins are installed"
  cd "$DIR/fish"
  mkdir -p "$HOME/.config/fish/functions"
  link_if_absent "$DIR/lib/fisherman/fisher.fish" "$HOME/.config/fish/functions/fisher.fish"
  link_if_absent "$DIR/fish/fishfile" "$HOME/.config/fish/fishfile"
  fish -c fisher
}

function link_fish_settings {
  step "Fish settings are present"
  fish "$DIR/fish/vars.fish"
  link_all_if_absent "$DIR/fish/functions" "$HOME/.config/fish/functions"
  link_all_if_absent "$DIR/fish/completions" "$HOME/.config/fish/completions"
  link_all_if_absent "$DIR/fish/conf" "$HOME/.config/fish/conf.d"
  fish -c fish_update_completions
}

function link_dotfiles {
  step "Dotfiles are linked"
  link_all_if_absent "$DIR/dotfiles" "$HOME"
}

function link_bin_files {
  step "User bin files are linked"
  cd "$DIR/bin"
  if [ ! -e "$BIN_HOME" ]; then
    echo "creating $BIN_HOME"
    mkdir "$BIN_HOME"
  fi
  link_all_if_absent "$DIR/bin" "$BIN_HOME"
}

main
