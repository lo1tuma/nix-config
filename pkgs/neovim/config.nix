{ pkgs }:

let
  plugins = [
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.popup-nvim
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.vim-javascript
    pkgs.vimPlugins.editorconfig-vim
    pkgs.vimPlugins.nvim-surround
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.vim-gitgutter
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.nvim-cmp
    pkgs.vimPlugins.cmp-buffer
    pkgs.vimPlugins.cmp-emoji
    pkgs.vimPlugins.cmp-path
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.SchemaStore-nvim
    pkgs.vimPlugins.which-key-nvim
    pkgs.vimPlugins.conform-nvim
    pkgs.vimPlugins.nvim-lint
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
  ];
in {
  vimAlias = true;
  plugins = plugins;
  withPython3 = true;
  extraPython3Packages = pythonPackages: [ pythonPackages.pynvim ];
  withNodeJs =true;
  autowrapRuntimeDeps = true;
}

