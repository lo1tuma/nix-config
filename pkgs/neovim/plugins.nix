{ pkgs, fetchgit }:

let
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
in {
  "nvim-typescript" = buildVimPlugin {
    name = "nvim-typescript";
    src = fetchgit {
      url = "https://github.com/mhartington/nvim-typescript";
      rev = "70e36b80113c2d84663b0f86885320022943dd51";
      sha256 = "13rgynm499hk3gyfsymqy59m4sfz8spvzqvh6pcd3a1zh6p9ar1l";
    };
    dependencies = [];
  };
}
