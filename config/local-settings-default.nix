{
  git = {
    userName = "Mathias Schreck";
    userEmail = "schreck.mathias@gmail.com";
    sshPublicKey = "~/.ssh/id_ed25519.pub";
  };
  nix = {
    autoOptimiseStore = true;
    hostPlatform = "aarch64-darwin";
    nixpkgsSource = "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  };
  packages = {
    nodejs = "nodejs_26";
  };
}
