{ config, pkgs, ... }:

let
  inherit (pkgs) zsh;
in {
  environment.etc = {
    "per-user/alacritty/alacritty.yml".text = import ../dotfiles/alacritty.nix { inherit zsh; };
    "per-user/.gitconfig".text = import ../dotfiles/gitconfig.nix {};
    "per-user/.gitignore".text = import ../dotfiles/gitignore.nix {};
    "per-user/.npmrc".text = import ../dotfiles/npmrc.nix {};
  };
  system.activationScripts.extraUserActivation.text = ''
    ln -sfn /etc/per-user/alacritty ~/.config/
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
      eval "$(starship init zsh)"
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
    extraConfig = ''
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

  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.nerdfonts ];
  };

  nix.maxJobs = 32;
  nix.buildCores = 4;
}
