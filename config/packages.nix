{ pkgs }:

let
  nvim = import ../pkgs/neovim/default.nix { inherit pkgs; };
in [
  pkgs.cacert
  pkgs.git
  pkgs.python
  pkgs.nodejs_20
  pkgs.zsh
  pkgs.wget
  pkgs.curl
  nvim
  pkgs.openssl
  pkgs.fd
  pkgs.exa
  pkgs.git-lfs
  pkgs.ripgrep
  pkgs.bashInteractive
  pkgs.nix-prefetch-scripts
  pkgs.alacritty
  pkgs.bat
  pkgs.fzf
  pkgs.gnupg
  pkgs.du-dust
  pkgs.starship
  pkgs.watchman
  pkgs.tokei
  pkgs.ruplacer
  pkgs.tree-sitter
]
