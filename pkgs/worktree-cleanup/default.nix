{ pkgs }:

pkgs.writeShellScriptBin "cleanup-worktrees" ''
  export PATH=${pkgs.git}/bin:${pkgs.git-lfs}/bin:$PATH
  exec ${pkgs.python3}/bin/python3 ${./cleanup.py} "$@"
''
