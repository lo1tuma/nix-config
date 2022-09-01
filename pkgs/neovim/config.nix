{ pkgs }:

let
  vimrc = pkgs.callPackage ./vimrc.nix {};
in {
  customRC = vimrc;
  packages.nix.start = [
    pkgs.vimPlugins.vim-json
    pkgs.vimPlugins.tabular
    pkgs.vimPlugins.vim-markdown
    pkgs.vimPlugins.vim-nix
    pkgs.vimPlugins.vim-javascript
    pkgs.vimPlugins.vim-nix
    pkgs.vimPlugins.typescript-vim
    pkgs.vimPlugins.editorconfig-vim
    pkgs.vimPlugins.vim-surround
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.vim-gitgutter
    pkgs.vimPlugins.coc-nvim
    pkgs.vimPlugins.coc-rls
    pkgs.vimPlugins.coc-yaml
    pkgs.vimPlugins.coc-neco
    pkgs.vimPlugins.coc-json
    pkgs.vimPlugins.coc-lists
    pkgs.vimPlugins.coc-eslint
    pkgs.vimPlugins.coc-tsserver
    pkgs.vimPlugins.coc-prettier
    pkgs.vimPlugins.echodoc
    pkgs.vimPlugins.base16-vim
    pkgs.vimPlugins.vim-toml
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.popup-nvim
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.nvim-web-devicons
  ];
}

