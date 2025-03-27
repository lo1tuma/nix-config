{ pkgs }:
let
    neovimConfig = pkgs.neovimUtils.makeNeovimConfig (import ./config.nix { inherit pkgs; });
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
    extraMakeWrapperArgs = "--prefix PATH : '${pkgs.lib.makeBinPath extraRuntimeDependencies}'";
in pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
  luaRcContent = let
        inherit (builtins) concatStringsSep readFile map;

        sources = [
          ./nviminit/lua/base-keymap.lua
          ./nviminit/lua/nviminit.lua
          ./nviminit/lua/syntax.lua
          ./nviminit/lua/telescope-settings.lua
          ./nviminit/lua/help.lua
          ./nviminit/lua/linter.lua
          ./nviminit/lua/lsp.lua
          ./nviminit/lua/formatter.lua
          ./nviminit/lua/completion.lua
        ];
      in concatStringsSep "\n" (map readFile sources);
  wrapperArgs = pkgs.lib.escapeShellArgs neovimConfig.wrapperArgs + " " + extraMakeWrapperArgs;
  wrapRc = true;
})
