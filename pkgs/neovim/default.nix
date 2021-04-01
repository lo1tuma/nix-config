{ pkgs }:

pkgs.neovim.override {
  vimAlias = true;
  configure = import ./config.nix { inherit pkgs; };
  extraPython3Packages = pythonPackages: [ pythonPackages.pynvim ];
  withNodeJs = true;
}
