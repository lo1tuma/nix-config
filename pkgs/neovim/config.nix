{ pkgs }:

let
  vimrc = pkgs.callPackage ./vimrc.nix {};
in {
  customRC = vimrc;
  vam = {
    knownPlugins = pkgs.vimPlugins;

    pluginDictionaries = [
      { name = "vim-json"; } # elzr/vim-json
      { name = "tabular"; } # godlygeek/tabular
      { name = "vim-markdown"; } # plasticboy/vim-markdown
      { name = "vim-nix"; } # LnL7/vim-nix
      { name = "vim-javascript"; } # pangloss/vim-javascript
      { name = "typescript-vim"; } # leafgarland/typescript-vim
      { name = "editorconfig-vim"; } # editorconfig/editorconfig-vim
      { name = "vim-surround"; } # tpope/vim-surround
      { name = "vim-repeat"; } # tpope/vim-repeat
      { name = "vim-gitgutter"; } # airblade/vim-gitgutter
      { name = "coc-nvim"; }
      { name = "coc-rls"; }
      { name = "coc-yaml"; }
      { name = "coc-neco"; }
      { name = "coc-json"; }
      { name = "coc-lists"; }
      { name = "coc-eslint"; }
      { name = "coc-tsserver"; }
      { name = "coc-prettier"; }
      { name = "echodoc"; }
      { name = "base16-vim"; }
      { name = "vim-toml"; }
      { name = "telescope-nvim"; }
      { name = "popup-nvim"; } # required by telescope
      { name = "plenary-nvim"; } # required by telescope
      { name = "nvim-treesitter"; } # require by telescope
      { name = "nvim-web-devicons"; }
    ];
  };
}

