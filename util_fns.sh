function get_editor {
  set +u
  if [ -z "$EDITOR" ]; then
    echo "vi"
  else
    echo $EDITOR
  fi
  set -u
}

function check_os {
  desired_os=$1
  if [ "$(uname)" != "$desired_os" ]; then
    echo "expected uname to be $desired_os but got $(uname)"
    exit 1
  fi
}

function link_if_absent {
  if [ ! -e "$2" ]; then
    ln -s "$1" "$2"
    echo "linked $1 to $2"
  elif [ "$(readlink $2)" = "$1" ]; then
    echo "link to $2 already exists"
  else
    echo "failure linking $1 to $2"
    exit 1
  fi
}

function sudo_link_if_absent {
  if [ ! -e "$2" ]; then
    sudo ln -s "$1" "$2"
    echo "linked $1 to $2"
  elif [ "$(sudo readlink $2)" = "$1" ]; then
    echo "link to $2 already exists"
  else
    echo "failure linking $1 to $2"
    exit 1
  fi
}

function link_all_if_absent {
  pushd "$1"
  for file in *; do
    link_if_absent "$1/$file" "$2/$file"
  done
  popd
}

function sudo_link_all_if_absent {
  pushd "$1"
  for file in *; do
    sudo_link_if_absent "$1/$file" "$2/$file"
  done
  popd
}

function append_if_absent {
  line=$1
  file=$2
  grep -q '^'"$line"'$' "$file" || echo "$line" >> $file
}

function sudo_append_if_absent {
  line=$1
  file=$2
  sudo grep -q '^'"$line"'$' "$file" || echo "$line" | sudo tee -a "$file"
}

function copy_if_absent {
  if [ ! -e "$2" ]; then
    cp "$1" "$2"
    echo "copied $1 to $2"
  elif diff "$1" "$2"; then
    echo "$2 already exists and is identical to $1"
  else
    echo "failure copying $1 to $2"
    exit 1
  fi
}

function sudo_copy_if_absent {
  if [ ! -e "$2" ]; then
    sudo cp "$1" "$2"
    echo "copied $1 to $2"
  elif sudo diff "$1" "$2"; then
    echo "$2 already exists and is identical to $1"
  else
    echo "failure copying $1 to $2"
    exit 1
  fi
}

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

function step {
  echo -e "\n\n\033[34;1;4m$@\033[0m"
}

function pushd {
    command pushd "$@" > /dev/null
}

function popd {
    command popd "$@" > /dev/null
}
