{ config, pkgs, ... }:

let
  cleanup = import ../pkgs/worktree-cleanup { inherit pkgs; };
  homeDir = "/Users/${config.system.primaryUser}";
in
{
  environment.systemPackages = [ cleanup ];
  launchd.user.agents.cleanup-worktrees = {
    command = "${cleanup}/bin/cleanup-worktrees --apply";
    serviceConfig = {
      RunAtLoad = true;
      StartCalendarInterval = {
        Minute = 0;
      };
      ProcessType = "Background";
      LowPriorityIO = true;
      StandardOutPath = "${homeDir}/Library/Logs/worktree-cleanup.log";
      StandardErrorPath = "${homeDir}/Library/Logs/worktree-cleanup.log";
    };
  };
}
