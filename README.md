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
* own skills live under `dotfiles/ai-agents/skills/`
* third-party skills are fetched per source repository at a pinned revision in `config/agent-dotfiles.nix`, never vendored; each one keeps its upstream licence beside it
* `darwin-rebuild switch` links managed files into `~/.codex` and `~/.claude`
* activation also ensures Codex accepts both `AGENTS.md` and `agents.md` as project instruction filenames
* the home directories stay real writable directories, so both tools can still create runtime state there

### Skill layers
* entry points are the skills invoked by hand, one per kind of work
* lenses carry the judgment an entry point needs; they install to `~/.agent-skill-library/` instead of the scanned skill directories, so they cost no context until something reads one
* `~/.agent-skill-library/CATALOG.md` is generated from the same nix attribute set that pins the skills, so it cannot drift from what is installed
* keeping lenses out of the scanned directories holds the skill list inside Codex's 8000-character budget; with everything visible it was roughly 23000

## tmux
* tmux restores the last saved layout after reboot via `tmux-resurrect` and `tmux-continuum`
* restore runs automatically when the tmux server starts
* use `tm` or `tmux-attach-latest` after reboot to attach the session that was active in the last saved layout
* manual save and restore: `prefix + Ctrl-s`, `prefix + Ctrl-r`

## Git
* `/usr/local/bin/git` points to Nix Git so default macOS PATH lookup avoids the Apple developer-tools shim
