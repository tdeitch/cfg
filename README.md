# cfg

As close as I care to come to declarative configuration management for my Macs.

## On a new Mac

1. `git clone --recurse-submodules git@github.com:tdeitch/cfg.git`

2. `cd cfg`

3. `./setup.sh`

## To update an existing Mac

1. Ensure the git repo is up to date with no uncommitted changes

2. `git submodule update --init --recursive` to update submodules

3. Run `setup.sh` to sync changes from cfg to the local computer

## To update cfg with local changes

1. Run `update.sh` to sync changes made on the computer to the repo

2. Review the changes and commit the ones you want to keep

3. (Optional) run `clean.sh` to remove packages from the computer before
   updating. This makes the subsequent setup step slower, so only do it if
   you've made changes outside of cfg that you want to remove from the computer.

4. Run `setup.sh` to sync changes from cfg back to the local computer

## To clean up old Homebrew packages

1. `brew bundle cleanup --global` (dry run)

2. `brew bundle cleanup --global --force` (for real)

## Troubleshooting

* Sometimes applications installed with homebrew-cask ask to move themselves to
  the `/Applications` folder, despite already being in that folder. Moving them
  to a different folder and then moving them back seems to solve the problem.
