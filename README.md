nix-config
========

This repository contains my darwin-specific nix configuration and dotfiles.

## Dependencies
* nix
* [nix-darwin](https://github.com/LnL7/nix-darwin)

## Install
* clone this repository to `$HOME/projects/nix-config`
* run `darwin-rebuild switch -I darwin-config=$HOME/projects/nix-config/config/default.nix`

## Local settings
* committed defaults live in `config/local-settings-default.nix`
* local overrides live in ignored `config/local-settings.nix`
* use local overrides for values like `git.userEmail`, `git.sshPublicKey`, `nix.hostPlatform`, `nix.nixpkgsSource`, `nix.autoOptimiseStore`, and `packages.nodejs`

## Agent dotfiles
* shared agent instructions live in `dotfiles/ai-agents/AGENTS.md`
* managed skills live under `dotfiles/ai-agents/skills/`
* `darwin-rebuild switch` links managed files into `~/.codex` and `~/.claude`
* activation also ensures Codex accepts both `AGENTS.md` and `agents.md` as project instruction filenames
* the home directories stay real writable directories, so both tools can still create runtime state there

## tmux
* tmux restores the last saved layout after reboot via `tmux-resurrect` and `tmux-continuum`
* restore runs automatically when the tmux server starts
* manual save and restore: `prefix + Ctrl-s`, `prefix + Ctrl-r`
