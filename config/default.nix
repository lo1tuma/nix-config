{ config, pkgs, ... }:

let
  pureZshPrompt = pkgs.fetchgit {
    url = "https://github.com/sindresorhus/pure";
    rev = "e7036c43487fedf608a988dde54dd1d4c0d96823";
    sha256 = "10mdk4dn2azzrhymx0ghl8v668ydy6mz5i797nmbl2ijx9hlqb3v";
  };
in {
  environment.etc = {
    "per-user/alacritty/alacritty.yml".text = import ../dotfiles/alacritty.nix { zsh = pkgs.zsh; };
    "per-user/.gitconfig".text = import ../dotfiles/gitconfig.nix {};
    "per-user/.gitignore".text = import ../dotfiles/gitignore.nix {};
    "per-user/.npmrc".text = import ../dotfiles/npmrc.nix {};
  };
  system.activationScripts.extraUserActivation.text = ''
    ln -sfn /etc/per-user/alacritty ~/.config/
    mkdir -p ~/.zfunctions
    ln -sfn ${pureZshPrompt}/pure.zsh ~/.zfunctions/prompt_pure_setup
    ln -sfn ${pureZshPrompt}/async.zsh ~/.zfunctions/async
    ln -sfn /etc/per-user/.gitconfig ~/
    ln -sfn /etc/per-user/.gitignore ~/
    ln -sfn /etc/per-user/.npmrc ~/
  '';
  environment.shells = [ pkgs.zsh ];
  environment.variables = rec {
    TERM = "screen-256color";
    LANG = "en_US.UTF-8";
    LC_ALL = LANG;
    LESSCHARSET = "utf-8";
  };
  system.defaults = import ./darwin.nix { inherit pkgs; };
  environment.systemPackages = import ./packages.nix { inherit pkgs; };

  nixpkgs = { config = { allowUnfree = true; allowBroken = false; }; };

  environment.darwinConfig = "$HOME/projects/nix-config/config/default.nix";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
    promptInit = ''
      fpath=( "$HOME/.zfunctions" $fpath )
      autoload -U promptinit && promptinit && prompt pure
    '';
    interactiveShellInit = ''
      autoload -U up-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      zle -N up-line-or-beginning-search
    '';
  };

  programs.tmux = {
    enable = true;
    enableMouse = false;
    enableVim = true;
    tmuxConfig = ''
      set -g default-terminal "screen-256color"
      set -sg escape-time 0
      set -sg status-right " "
      set -sg status-left " "
      set -sg status-left-length 10
      set -sg status-right-length 10
    '';
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;

  nix.maxJobs = 32;
  nix.buildCores = 4;
}
