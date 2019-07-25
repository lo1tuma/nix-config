{ pkgs }:

let
  nvim = import ../pkgs/neovim/default.nix { inherit pkgs; };
in [
  pkgs.cacert
  pkgs.git
  pkgs.python
  pkgs.nodejs-10_x
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
]
