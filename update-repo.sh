#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
shopt -s dotglob

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$DIR"

function main {
  echo "Updating submodules..."
  git submodule update --recursive --remote

  echo "Updating Brewfile..."
  brewfile=$(get_new_brewfile)
  if [ -s "$brewfile" ]; then
    echo "New packages in Brewfile.new"
    cp "$brewfile" "$DIR/Brewfile.new"
  else
    echo "No new Homebrew packages"
  fi
}

function get_new_brewfile {
  tmp_dumpfile=$(mktemp)
  tmp_oldfile=$(mktemp)
  tmp_newfile=$(mktemp)
  brew bundle dump --force --file="$tmp_dumpfile"
  cat "$DIR/Brewfile" "$HOME/.Brewfile.local" > "$tmp_oldfile"
  sort -o "$tmp_dumpfile" "$tmp_dumpfile"
  sort -o "$tmp_oldfile" "$tmp_oldfile"
  comm -23 "$tmp_dumpfile" "$tmp_oldfile" > "$tmp_newfile"

  tmp_tapfile=$(mktemp)
  tmp_pkgfile=$(mktemp)
  tmp_brewfile=$(mktemp)
  grep '^tap' "$tmp_newfile" > "$tmp_tapfile" || true
  grep -v '^tap' "$tmp_newfile" > "$tmp_pkgfile" || true
  sort -o "$tmp_tapfile" "$tmp_tapfile"
  sort -o "$tmp_pkgfile" "$tmp_pkgfile"
  cat "$tmp_tapfile" "$tmp_pkgfile" > "$tmp_brewfile"
  echo "$tmp_brewfile"
}

main
