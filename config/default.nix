{ pkgs, ... }:

let
  primaryUser = "mschreck";
  homeDir = "/Users/${primaryUser}";
  configDir = "${homeDir}/.config";
  repoRoot = "${homeDir}/projects/nix-config";
  localSettings = pkgs.lib.recursiveUpdate (import ./local-settings-default.nix) (
    if builtins.pathExists ./local-settings.nix then import ./local-settings.nix else { }
  );
  systemZsh = "/run/current-system/sw/bin/zsh";
  perUserLinks = {
    ".gitconfig" = "/etc/per-user/.gitconfig";
    ".gitignore" = "/etc/per-user/.gitignore";
    ".npmrc" = "/etc/per-user/.npmrc";
    ".config/alacritty" = "/etc/per-user/alacritty";
  };
  linkCommand = path: target: "ln -sfn ${target} ${homeDir}/${path}";
  activationLinks = pkgs.lib.mapAttrsToList linkCommand perUserLinks;
  trackpadDefaults = ''
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    /usr/bin/defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    /usr/bin/defaults write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
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
      auto-optimise-store = true
    '';
  };
  system.activationScripts.postActivation.text = pkgs.lib.concatStringsSep "\n" (
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
  environment.systemPackages = import ./packages.nix { inherit pkgs; };

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
      set -g @catppuccin_window_status_style "custom"
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " | "
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_current_text "#{b:pane_current_path}"
      set -g @catppuccin_window_default_text "#{b:pane_current_path}"
      set -g @catppuccin_status_left_separator ""
      set -g @catppuccin_status_right_separator "█"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "yes"
      set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M"
      set -g @catppuccin_session_text "#{?client_prefix,#S: prefix,#S: normal}"

      set -g @continuum-restore 'on'

      set -sg escape-time 0
      set-option -g default-shell "${systemZsh}"
      set-option -g default-command "exec ${systemZsh} -l"
      set-option -g focus-events on

      set -g default-terminal "alacritty"
      set-option -a terminal-overrides ",alacritty:RGB"

      run-shell ${catppuccinTmux}/share/tmux-plugins/catppuccin/catppuccin.tmux
      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}

      set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_session}"

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
  nix.enable = false;
}
