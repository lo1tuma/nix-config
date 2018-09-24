nix-config
========

This repository contains my darwin-specific nix configuration and dotfiles.

## Dependencies
* nix
* [nix-darwin](https://github.com/LnL7/nix-darwin)

## Install
* clone this repository to `$HOME/projects/nix-config`
* run `darwin-rebuild switch -I darwin-config=$HOME/projects/nix-config/config/default.nix`
