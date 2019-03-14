# cfg

As close as I care to come to declarative configuration management for my Macs.

## On a new Mac

1. `git clone --recurse-submodules git@github.com:tdeitch/cfg.git`

2. `cd cfg`

3. `./setup.sh`

## To update an existing Mac

1. Ensure the git repo is up to date with no uncommitted changes.

2. (Optional) Run `update-repo.sh` to sync changes (see next section).

3. Run `setup.sh` to sync changes from cfg to the local computer.

## To update cfg with local changes

1. Run `update-repo.sh` to sync changes made on the computer to the repo.

2. Review the changes and commit the ones you want to keep.

3. (Optional) Run `brew bundle cleanup --global` to clean up Homebrew packages
   that are installed on the computer but not listed in the Brewfile. Run with
   `--force` once you are sure you want to remove the listed packages.

4. Run `setup.sh` to sync changes from cfg back to the local computer.

## Troubleshooting

* Sometimes applications installed with homebrew-cask ask to move themselves to
  the `/Applications` folder, despite already being in that folder. Moving them
  to a different folder and then moving them back seems to solve the problem.
