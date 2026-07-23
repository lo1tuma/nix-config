{ lib, pkgs, ... }:

let
  primaryUser = "mschreck";
  homeDir = "/Users/${primaryUser}";
  configDir = "${homeDir}/.config";
  repoRoot = "${homeDir}/projects/nix-config";
  localSettings = lib.recursiveUpdate (import ./local-settings-default.nix) (
    if builtins.pathExists ./local-settings.nix then import ./local-settings.nix else { }
  );
  systemZsh = "/run/current-system/sw/bin/zsh";
  claudeCode =
    (import
      (builtins.fetchTarball {
        url = localSettings.nix.nixpkgsSource;
      })
      {
        system = localSettings.nix.hostPlatform;
        config.allowUnfree = true;
      }
    ).claude-code;
  perUserLinks = {
    ".gitconfig" = "/etc/per-user/.gitconfig";
    ".gitignore" = "/etc/per-user/.gitignore";
    ".npmrc" = "/etc/per-user/.npmrc";
    ".config/alacritty" = "/etc/per-user/alacritty";
  };
  linkCommand = path: target: "ln -sfn ${target} ${homeDir}/${path}";
  activationLinks = lib.mapAttrsToList linkCommand perUserLinks;
  trackpadDefaults = ''
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.threeFingerDragGesture -bool false
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 2
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.fourFingerVertSwipeGesture -int 2
  '';
  reduceSpotlightIndexing = ''
    /usr/bin/mdutil -i off /nix >/dev/null 2>&1 || true
  '';
  disableBackgroundWake = ''
    /usr/bin/pmset -a powernap 0 tcpkeepalive 0 >/dev/null 2>&1 || true
  '';
  configureFirewallLogging = ''
    /usr/bin/defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true >/dev/null 2>&1 || true
    /usr/bin/defaults write /Library/Preferences/com.apple.alf loggingoption -string brief >/dev/null 2>&1 || true
    launchctl kickstart -k system/com.apple.alf >/dev/null 2>&1 || true
  '';
  disableTtyWake = ''
    /usr/bin/pmset -a ttyskeepawake 0 >/dev/null 2>&1 || true
  '';
  disableProximityWake = ''
    /usr/bin/pmset -a proximitywake 0 >/dev/null 2>&1 || true
  '';
  warnEnforcedUpdate = ''
    enforced=$(/usr/bin/log show --last 26h \
      --predicate 'process == "softwareupdated" AND eventMessage CONTAINS "EnforcedInstallDate"' 2>/dev/null \
      | /usr/bin/grep -oE 'EnforcedInstallDate:[0-9-]+T[0-9:]+' \
      | /usr/bin/sort -u | /usr/bin/tail -1 | /usr/bin/sed 's/EnforcedInstallDate://')
    [ -n "''${enforced:-}" ] || exit 0
    /usr/bin/osascript -e "display notification \"macOS will force-install an update and RESTART at ''${enforced}. Save your work and install on your own terms first: sudo softwareupdate -ia --restart\" with title \"MDM update deadline approaching\" sound name \"Basso\"" >/dev/null 2>&1 || true
  '';
  claudeLauncher = pkgs.writeShellScriptBin "claude" ''
    set -u

    pass_through=0
    sid=""
    prev=""
    for arg in "$@"; do
      case "$prev" in
        -r|--resume|--session-id) sid="$arg" ;;
      esac
      case "$arg" in
        -r|--resume|--session-id|-c|--continue|--from-pr) pass_through=1 ;;
      esac
      prev="$arg"
    done

    if [ "$pass_through" -eq 0 ]; then
      sid="$(/usr/bin/uuidgen | /usr/bin/tr 'A-Z' 'a-z')"
      set -- --session-id "$sid" "$@"
    fi

    if [ -n "''${TMUX:-}" ] && [ -n "$sid" ]; then
      tmux set -p @claude_session_id "$sid" >/dev/null 2>&1 || true
    fi

    exec ${claudeCode}/bin/claude "$@"
  '';
  tmuxSaveClaudeSessions = pkgs.writeShellScriptBin "tmux-save-claude-sessions" ''
    set -u
    dir="$HOME/.tmux/resurrect"
    mkdir -p "$dir"
    tab=$(printf '\t')
    tmux list-panes -a \
      -F "#{session_name}$tab#{window_index}$tab#{pane_index}$tab#{@claude_session_id}" \
      | awk -F"$tab" 'NF==4 && $4 != ""' > "$dir/claude-map.tsv" || true
  '';
  tmuxRestoreClaudeAgents = pkgs.writeShellScriptBin "tmux-restore-claude-agents" ''
    set -u
    map="$HOME/.tmux/resurrect/claude-map.tsv"
    [ -f "$map" ] || exit 0
    tab=$(printf '\t')
    while IFS="$tab" read -r sess win pane sid; do
      [ -n "''${sid:-}" ] || continue
      tmux send-keys -t "$sess:$win.$pane" "claude --resume $sid" C-m >/dev/null 2>&1 || true
    done < "$map"
  '';
  tmuxLauncher = pkgs.writeShellScriptBin "tm" ''
    set -u
    if tmux has-session >/dev/null 2>&1; then
      exec tmux attach
    fi
    tmux start-server
    i=0
    while [ "$i" -lt 40 ]; do
      if tmux has-session >/dev/null 2>&1; then
        exec tmux attach
      fi
      /bin/sleep 0.25
      i=$((i + 1))
    done
    exec tmux new-session
  '';
  disableAirPlayReceiver = ''
    airplay_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout system/com.apple.AirPlayXPCHelper >/dev/null 2>&1 || true
    launchctl disable system/com.apple.AirPlayXPCHelper >/dev/null 2>&1 || true

    launchctl bootout "$airplay_gui_domain"/com.apple.AirPlayUIAgent >/dev/null 2>&1 || true
    launchctl disable "$airplay_gui_domain"/com.apple.AirPlayUIAgent >/dev/null 2>&1 || true
  '';
  disableAirDrop = ''
    sharing_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout "$sharing_gui_domain"/com.apple.sharingd >/dev/null 2>&1 || true
    launchctl disable "$sharing_gui_domain"/com.apple.sharingd >/dev/null 2>&1 || true
  '';
  disableDictation = ''
    dictation_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout "$dictation_gui_domain"/com.apple.DictationIM >/dev/null 2>&1 || true
    launchctl disable "$dictation_gui_domain"/com.apple.DictationIM >/dev/null 2>&1 || true
  '';
  disableVoiceOver = ''
    voiceover_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout "$voiceover_gui_domain"/com.apple.VoiceOver >/dev/null 2>&1 || true
    launchctl disable "$voiceover_gui_domain"/com.apple.VoiceOver >/dev/null 2>&1 || true
  '';
  disableSwitchControl = ''
    switch_control_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout "$switch_control_gui_domain"/com.apple.AssistiveControl >/dev/null 2>&1 || true
    launchctl disable "$switch_control_gui_domain"/com.apple.AssistiveControl >/dev/null 2>&1 || true
  '';
  disableDwellControl = ''
    dwell_control_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout "$dwell_control_gui_domain"/com.apple.DwellControl >/dev/null 2>&1 || true
    launchctl disable "$dwell_control_gui_domain"/com.apple.DwellControl >/dev/null 2>&1 || true
  '';
  disableRemoteAppleEvents = ''
    /usr/sbin/systemsetup -setremoteappleevents off >/dev/null
  '';
  disableRemoteManagement = ''
    remote_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout system/com.apple.screensharing >/dev/null 2>&1 || true
    launchctl disable system/com.apple.screensharing >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.RemoteDesktop.PrivilegeProxy >/dev/null 2>&1 || true
    launchctl disable system/com.apple.RemoteDesktop.PrivilegeProxy >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.remotemanagementd >/dev/null 2>&1 || true
    launchctl disable system/com.apple.remotemanagementd >/dev/null 2>&1 || true

    launchctl bootout "$remote_gui_domain"/com.apple.RemoteDesktop.agent >/dev/null 2>&1 || true
    launchctl disable "$remote_gui_domain"/com.apple.RemoteDesktop.agent >/dev/null 2>&1 || true

    launchctl bootout "$remote_gui_domain"/com.apple.RemoteManagementAgent >/dev/null 2>&1 || true
    launchctl disable "$remote_gui_domain"/com.apple.RemoteManagementAgent >/dev/null 2>&1 || true

    launchctl bootout "$remote_gui_domain"/com.apple.screensharing.agent >/dev/null 2>&1 || true
    launchctl disable "$remote_gui_domain"/com.apple.screensharing.agent >/dev/null 2>&1 || true

    launchctl bootout "$remote_gui_domain"/com.apple.screensharing.MessagesAgent >/dev/null 2>&1 || true
    launchctl disable "$remote_gui_domain"/com.apple.screensharing.MessagesAgent >/dev/null 2>&1 || true
  '';
  disableFileSharing = ''
    launchctl bootout system/com.apple.smbd >/dev/null 2>&1 || true
    launchctl disable system/com.apple.smbd >/dev/null 2>&1 || true
  '';
  disableInternetSharing = ''
    launchctl bootout system/com.apple.NetworkSharing >/dev/null 2>&1 || true
    launchctl disable system/com.apple.NetworkSharing >/dev/null 2>&1 || true
  '';
  disableMediaSharing = ''
    media_gui_domain="gui/$(id -u -- ${primaryUser})"
    launchctl bootout "$media_gui_domain"/com.apple.amp.mediasharingd >/dev/null 2>&1 || true
    launchctl disable "$media_gui_domain"/com.apple.amp.mediasharingd >/dev/null 2>&1 || true
  '';
  disableContentCaching = ''
    cache_gui_domain="gui/$(id -u -- ${primaryUser})"

    launchctl bootout system/com.apple.AssetCache.builtin >/dev/null 2>&1 || true
    launchctl disable system/com.apple.AssetCache.builtin >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.AssetCacheManagerService >/dev/null 2>&1 || true
    launchctl disable system/com.apple.AssetCacheManagerService >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.AssetCacheTetheratorService >/dev/null 2>&1 || true
    launchctl disable system/com.apple.AssetCacheTetheratorService >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.AssetCacheLocatorService >/dev/null 2>&1 || true
    launchctl disable system/com.apple.AssetCacheLocatorService >/dev/null 2>&1 || true

    launchctl bootout "$cache_gui_domain"/com.apple.AssetCache.agent >/dev/null 2>&1 || true
    launchctl disable "$cache_gui_domain"/com.apple.AssetCache.agent >/dev/null 2>&1 || true
  '';
  disableLocationServices = ''
    location_gui_domain="gui/$(id -u -- ${primaryUser})"

    /usr/bin/defaults write /private/var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 0 >/dev/null 2>&1 || true
    find /private/var/db/locationd/Library/Preferences/ByHost -maxdepth 1 -name 'com.apple.locationd*.plist' -exec /usr/sbin/chown _locationd:_locationd {} + >/dev/null 2>&1 || true

    launchctl bootout system/com.apple.locationd >/dev/null 2>&1 || true
    launchctl disable system/com.apple.locationd >/dev/null 2>&1 || true

    launchctl bootout "$location_gui_domain"/com.apple.CoreLocationAgent >/dev/null 2>&1 || true
    launchctl disable "$location_gui_domain"/com.apple.CoreLocationAgent >/dev/null 2>&1 || true
  '';
  catppuccinTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "2.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "v2.3.0";
      sha256 = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
    };
  };
in
{
  imports = [
    ./agent-dotfiles.nix
    ./defaults-activation.nix
  ];

  system.primaryUser = primaryUser;
  environment.etc = {
    "per-user/alacritty/alacritty.toml".text = import ../dotfiles/alacritty.nix {
      shellProgram = systemZsh;
    };
    "per-user/.gitconfig".text = import ../dotfiles/gitconfig.nix {
      git = localSettings.git;
    };
    "per-user/.gitignore".text = import ../dotfiles/gitignore.nix { };
    "per-user/.npmrc".text = import ../dotfiles/npmrc.nix { };
    "nix/nix.custom.conf".text = ''
      max-jobs = 32
      cores = 8
      nix-path = nixpkgs=${localSettings.nix.nixpkgsSource}
      auto-optimise-store = ${lib.boolToString localSettings.nix.autoOptimiseStore}
    '';
  };
  system.activationScripts.postActivation.text = lib.concatStringsSep "\n" (
    [
      "mkdir -p ${configDir}"
      disableBackgroundWake
      configureFirewallLogging
      disableTtyWake
      disableProximityWake
      disableAirPlayReceiver
      disableAirDrop
      disableDictation
      disableVoiceOver
      disableSwitchControl
      disableDwellControl
      reduceSpotlightIndexing
      disableRemoteAppleEvents
      disableRemoteManagement
      disableFileSharing
      disableInternetSharing
      disableMediaSharing
      disableContentCaching
      disableLocationServices
      trackpadDefaults
    ]
    ++ activationLinks
  );
  environment.shells = [ pkgs.zsh ];
  environment.variables = rec {
    LANG = "en_US.UTF-8";
    LC_ALL = LANG;
    LESSCHARSET = "utf-8";
  };
  system.defaults = import ./darwin.nix { inherit pkgs; };
  environment.systemPackages =
    import ./packages.nix {
      inherit pkgs;
      packages = localSettings.packages;
    }
    ++ [
      claudeLauncher
      tmuxSaveClaudeSessions
      tmuxRestoreClaudeAgents
      tmuxLauncher
    ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };
    hostPlatform = localSettings.nix.hostPlatform;
  };

  environment.darwinConfig = "${repoRoot}/config/default.nix";

  networking.applicationFirewall = {
    allowSigned = true;
    allowSignedApp = true;
    blockAllIncoming = false;
    enable = true;
    enableStealthMode = true;
  };
  networking.wakeOnLan.enable = false;
  services.openssh.enable = false;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';

    interactiveShellInit = ''
      autoload -U up-line-or-beginning-search
      zle -N up-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search

      npm() {
        command node --dns-result-order=ipv4first "$(whence -p npm)" "$@"
      }

      alias git="git config --unset --local core.hooksPath; git"
    '';
  };

  programs.tmux = {
    enable = true;
    enableMouse = false;
    enableVim = true;
    extraConfig = ''
      set -g @catppuccin_flavor 'mocha'
      set -g @catppuccin_window_status_style "rounded"
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_current_text "#{b:pane_current_path}"
      set -g @catppuccin_window_text "#{b:pane_current_path}"
      set -g @catppuccin_status_left_separator ""
      set -g @catppuccin_status_right_separator "█"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "yes"
      set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M"
      set -g @catppuccin_session_text "#{?client_prefix,#S: prefix,#S: normal}"

      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '5'
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-hook-post-save-all '${tmuxSaveClaudeSessions}/bin/tmux-save-claude-sessions'
      set -g @resurrect-hook-post-restore-all '${tmuxRestoreClaudeAgents}/bin/tmux-restore-claude-agents'

      set -sg escape-time 0
      set-option -g default-shell "${systemZsh}"
      set-option -g default-command "exec ${systemZsh} -l"
      set-option -g focus-events on

      set -g default-terminal "alacritty"
      set-option -a terminal-overrides ",alacritty:RGB"

      run-shell ${catppuccinTmux}/share/tmux-plugins/catppuccin/catppuccin.tmux

      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}

      # dev-split: (ctrl-b + ctrl-d) two splits with vim open in big pane
      bind-key C-d split-window -c "#{pane_current_path}" -v -l 13 \; \
        select-pane -T "tests/shell" \; \
        select-pane -t 0 \; \
        send-keys "vim '+Telescope find_files'" 'Enter' \; \

      # git-popup: (ctrl-b + ctrl-g)
      bind-key C-g display-popup -E -d "#{pane_current_path}" -xC -yC -w 80% -h 75% "git status && exec ${systemZsh} -il"
    '';
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;

  fonts = {
    packages = [
      pkgs.nerd-fonts.fira-code
    ];
  };

  power = {
    restartAfterFreeze = false;
    sleep = {
      allowSleepByPowerButton = false;
      computer = 15;
      display = 15;
    };
  };
  launchd.user.agents.trackpad-defaults = {
    script = trackpadDefaults;
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
  };
  launchd.user.agents.enforced-update-warning = {
    script = warnEnforcedUpdate;
    serviceConfig = {
      RunAtLoad = true;
      StartInterval = 7200;
    };
  };
  nix.enable = false;
}
