#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

source util_fns.sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"
EDITOR="$(get_editor)"

function main {
  sudo_validate
  load_terminal_theme
  link_templates
  source "$HOME/.cfgrc" # loaded in link_templates
  install_xcode_tools
  set_file_limits 65536 # also set with launch daemons
  install_homebrew
  install_homebrew_packages
  install_xcode
  install_fisherman_plugins
  prompt_for_fish
  set_fish_variables
  link_fish_functions
  link_fish_completions
  link_fish_config_files
  install_python_packages
  install_node_packages
  install_ruby_packages
  link_dotfiles
  link_launchd_files
  link_bin_files
  git_init_templates
}

function load_terminal_theme {
  echo "Ensure Solarized dark is installed"
  if [ "$(defaults read com.apple.Terminal.plist 'Default Window Settings')" != "Solarized Dark ansi" ]; then
    open "$DIR/lib/solarized/osx-terminal.app-colors-solarized/Solarized Dark ansi.terminal"
    echo "Set this terminal theme to default and option as meta (under the keyboard tab)"
    read -p "Press enter to continue "
  fi
}

function link_templates {
  echo "Ensure templates are present"
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
      eval $EDITOR "$HOME/$template"
    fi
  done
}

function install_xcode_tools {
  echo "Ensure XCode command-line tools are present"
  if ! xcode-select -p; then
    xcode-select --install
  fi
}

function set_file_limits {
  echo "Ensure open file limits are set"
  maxfiles=$1
  sudo_append_if_absent "kern.maxfiles=$maxfiles" "/etc/sysctl.conf"
  sudo_append_if_absent "kern.maxfilesperproc=$maxfiles" "/etc/sysctl.conf"
  sudo sysctl -w kern.maxfiles=$maxfiles
  sudo sysctl -w kern.maxfilesperproc=$maxfiles
  sudo sort -o "/etc/sysctl.conf" "/etc/sysctl.conf"
}

function install_homebrew {
  echo "Ensure Homebrew is present and up to date"
  if ! [ -x "$(command -v brew)" ]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew update
}

function install_homebrew_packages {
  echo "Ensure Homebrew packages are installed"
  cd "$DIR"
  link_if_absent "$DIR/packages/Brewfile" "$HOME/.Brewfile"
  brew bundle --global
  brew upgrade
  brew cask upgrade
  mas upgrade
  brew cleanup
}

function install_xcode {
  echo "Run any remaining Xcode first launch tasks"
  if xcodebuild -checkFirstLaunchStatus; then
    sudo xcodebuild -runFirstLaunch
  fi
}

function install_python_packages {
  echo "Ensure pip packages are installed"
  cd "$DIR/packages"
  pip2 install --upgrade pip
  xargs pip2 install < pip2-requirements.txt
  bash -c "pip2 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip2 install -U; true"
  pip3 install --upgrade pip
  xargs pip3 install < pip3-requirements.txt
  bash -c "pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U; true"
}

function install_node_packages {
  echo "Ensure npm packages are installed"
  npm update -g
  xargs npm install -g < npm-packages.txt
}

function install_ruby_packages {
  echo "Ensure gems are installed"
  gem update --system
  gem update
  xargs gem install < gems.txt
}

function install_fisherman_plugins {
  echo "Ensure fisherman plug-ins are installed"
  cd "$DIR/fish"
  mkdir -p "$HOME/.config/fish/functions"
  link_if_absent "$DIR/lib/fisherman/fisher.fish" "$HOME/.config/fish/functions/fisher.fish"
  fish -c "fisher ls" | grep -q '^fisherman/z$' || fish -c "fisher add fisherman/z"
}

function prompt_for_fish {
  echo "Check that this script is running in fish"
  if [[ ! "$SHELL" =~ "fish" ]]; then
    echo "Set the login shell to fish, re-open a terminal, and try again."
    echo "Current login shell: $SHELL"
  fi
}

function set_fish_variables {
  echo "Ensure fish variables are set"
  fish "$DIR/fish/vars.fish"

  echo "Ensure secret fish variables are set"
  fish "$DIR/fish/secret_vars.fish"
}

function link_fish_functions {
  echo "Ensure fish functions are present"
  link_all_if_absent "$DIR/fish/functions" "$HOME/.config/fish/functions"
}

function link_fish_completions {
  echo "Ensure fish completions are present"
  link_all_if_absent "$DIR/fish/completions" "$HOME/.config/fish/completions"
}

function link_fish_config_files {
  echo "Ensure fish config files are present"
  link_all_if_absent "$DIR/fish/conf" "$HOME/.config/fish/conf.d"
}

function link_dotfiles {
  echo "Ensure dotfiles are linked"
  link_all_if_absent "$DIR/dotfiles" "$HOME"
}

function link_launchd_files {
  echo "Ensure system LaunchDaemons are linked"
  cd "$DIR/launchd/system-daemons"
  for daemon in *; do
    sudo_copy_if_absent "$DIR/launchd/system-daemons/$daemon" "/Library/LaunchDaemons/$daemon"
    sudo chown root:wheel "/Library/LaunchDaemons/$daemon"
    sudo chmod 644 "/Library/LaunchDaemons/$daemon"
    sudo launchctl load -w "/Library/LaunchDaemons/$daemon"
  done

  echo "Ensure user LaunchAgents are linked"
  mkdir -p "$HOME/Library/LaunchAgents/"
  cd "$DIR/launchd/user-agents"
  for agent in *; do
    copy_if_absent "$DIR/launchd/user-agents/$agent" "$HOME/Library/LaunchAgents/$agent"
    chmod 644 "$HOME/Library/LaunchAgents/$agent"
    launchctl load -w "$HOME/Library/LaunchAgents/$agent"
  done
}

function link_bin_files {
  echo "Ensure bin executables are linked"
  cd "$DIR/bin"
  if [ ! -e "$BIN_HOME" ]; then
    echo "creating $BIN_HOME"
    mkdir "$BIN_HOME"
  fi
  link_all_if_absent "$DIR/bin" "$BIN_HOME"
}

function git_init_templates {
  echo "Ensure all projects use latest git templates"
  bash -c "find $CODE_HOME -name .git -print -execdir git init \; ; true"
}

main
