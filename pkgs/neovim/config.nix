{ pkgs }:

let
  nviminit = pkgs.vimUtils.buildVimPlugin {
    name = "nviminit";
    src = ./nviminit;
  };
  plugins = [
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.popup-nvim
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
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
    pkgs.vimPlugins.none-ls-nvim
    nviminit
  ];
in {
  customRC = "lua require('nviminit')";
  packages.myPlugins.start = plugins;
}

