{ pkgs }:

let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
    bash
    c
    diff
    editorconfig
    git_config
    gitcommit
    gitignore
    html
    javascript
    jsdoc
    json
    lua
    luadoc
    markdown
    markdown_inline
    nix
    query
    regex
    tmux
    toml
    tsx
    typescript
    vim
    vimdoc
    yaml
  ]);
  plugins = [
    pkgs.vimPlugins.catppuccin-nvim
    pkgs.vimPlugins.popup-nvim
    pkgs.vimPlugins.plenary-nvim
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
    treesitter
  ];
in {
  vimAlias = true;
  plugins = plugins;
  withPython3 = true;
  extraPython3Packages = pythonPackages: [ pythonPackages.pynvim ];
  withNodeJs = true;
  autowrapRuntimeDeps = true;
}
