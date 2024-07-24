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
in pkgs.neovim.override {
    vimAlias = true;
    configure = import ./config.nix { inherit pkgs; };
    extraPython3Packages = pythonPackages: [ pythonPackages.pynvim ];
    withNodeJs = true;
    extraMakeWrapperArgs = "--prefix PATH : '${pkgs.lib.makeBinPath extraRuntimeDependencies}'";
}
