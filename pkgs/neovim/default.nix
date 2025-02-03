{ pkgs }:
let
    extraRuntimeDependencies = [
        pkgs.vscode-langservers-extracted
        pkgs.nodePackages.cspell
        pkgs.nodePackages.typescript-language-server
        pkgs.lua-language-server
        pkgs.nil
        pkgs.stylua
        pkgs.shfmt
        pkgs.yaml-language-server
    ];
    neovimConfig = pkgs.neovimUtils.makeNeovimConfig (import ./config.nix { inherit pkgs; });
in pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig 
