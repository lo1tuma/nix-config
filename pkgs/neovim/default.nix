{ pkgs }:
let
  config = import ./config.nix { inherit pkgs; };
  extraRuntimeDependencies = [
    pkgs.vscode-langservers-extracted
    pkgs.cspell
    pkgs.dprint
    pkgs.nixfmt
    pkgs.prettier
    pkgs.tree-sitter
    pkgs.typescript-language-server
    pkgs.lua-language-server
    pkgs.nil
    pkgs.stylua
    pkgs.shfmt
    pkgs.yaml-language-server
  ];
  extraMakeWrapperArgs = "--prefix PATH : '${pkgs.lib.makeBinPath extraRuntimeDependencies}'";
  luaRcContent =
    let
      inherit (builtins) concatStringsSep map readFile;

      sources = [
        ./nviminit/lua/base-keymap.lua
        ./nviminit/lua/nviminit.lua
        ./nviminit/lua/syntax.lua
        ./nviminit/lua/git.lua
        ./nviminit/lua/telescope-settings.lua
        ./nviminit/lua/help.lua
        ./nviminit/lua/linter.lua
        ./nviminit/lua/lsp.lua
        ./nviminit/lua/formatter.lua
        ./nviminit/lua/completion.lua
      ];
    in
    concatStringsSep "\n" (map readFile sources);
in
pkgs.wrapNeovim pkgs.neovim-unwrapped {
  inherit extraMakeWrapperArgs;
  inherit (config) vimAlias withPython3 extraPython3Packages withNodeJs;

  configure = {
    customRC = ''
      lua << EOF
      ${luaRcContent}
      EOF
    '';
    packages.myNeovimPackage.start = config.plugins;
  };
}
