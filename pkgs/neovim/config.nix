{ pkgs }:

let
  vimrc = pkgs.callPackage ./vimrc.nix {};
  plugins = pkgs.callPackage ./plugins.nix {};
in {
  customRC = vimrc;
  vam = {
    knownPlugins = pkgs.vimPlugins // plugins;

    pluginDictionaries = [
      { name = "vim-json"; } # elzr/vim-json
      { name = "tabular"; } # godlygeek/tabular
      { name = "vim-markdown"; } # plasticboy/vim-markdown
      { name = "ctrlp"; } # ctrlpvim/ctrlp.vim
      { name = "vim-nix"; } # LnL7/vim-nix
      { name = "vim-javascript"; } # pangloss/vim-javascript
      { name = "typescript-vim"; } # leafgarland/typescript-vim
      { name = "editorconfig-vim"; } # editorconfig/editorconfig-vim
      { name = "vim-surround"; } # tpope/vim-surround
      { name = "vim-repeat"; } # tpope/vim-repeat
      { name = "vim-gitgutter"; } # airblade/vim-gitgutter
      { name = "deoplete-nvim"; } # Shougo/deoplete.nvim
      { name = "ale"; } # w0rp/ale
      { name = "echodoc"; }
      { name = "nvim-typescript"; }
      { name = "base16-vim"; }
      { name = "LanguageClient-neovim"; }
      { name = "vim-toml"; }
    ];
  };
}

