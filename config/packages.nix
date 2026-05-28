{ pkgs }:

let
  nvim = import ../pkgs/neovim/default.nix { inherit pkgs; };
in
[
  pkgs.cacert
  pkgs.git
  pkgs.python3
  pkgs.nodejs_26
  pkgs.zsh
  pkgs.wget
  pkgs.curl
  nvim
  pkgs.openssl
  pkgs.fd
  pkgs.eza
  pkgs.git-lfs
  pkgs.ripgrep
  pkgs.bashInteractive
  pkgs.alacritty
  pkgs.bat
  pkgs.fzf
  pkgs.gnupg
  pkgs.dust
  pkgs.starship
  pkgs.tokei
  pkgs.ruplacer
  pkgs.xh
]
