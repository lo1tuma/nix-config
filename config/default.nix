{ pkgs, ... }:

let
  primaryUser = "mschreck";
  homeDir = "/Users/${primaryUser}";
  configDir = "${homeDir}/.config";
  repoRoot = "${homeDir}/projects/nix-config";
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
  catppuccinTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2023-09-11";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "89ad057ebd47a3052d55591c2dcab31be3825a49";
      sha256 = "sha256-4JFuX9clpPr59vnCUm6Oc5IOiIc/v706fJmkaCiY2Hc=";
    };
    postInstall = ''
      sed -i -e 's|''${PLUGIN_DIR}/catppuccin-selected-theme.tmuxtheme|''${TMUX_TMPDIR}/catppuccin-selected-theme.tmuxtheme|g' $target/catppuccin.tmux
    '';
  };
in
{
  system.primaryUser = primaryUser;
  environment.etc = {
    "per-user/alacritty/alacritty.toml".text = import ../dotfiles/alacritty.nix {
      shellProgram = systemZsh;
    };
    "per-user/.gitconfig".text = import ../dotfiles/gitconfig.nix { };
    "per-user/.gitignore".text = import ../dotfiles/gitignore.nix { };
    "per-user/.npmrc".text = import ../dotfiles/npmrc.nix { };
  };
  system.activationScripts.postActivation.text = pkgs.lib.concatStringsSep "\n" (
    [
      "mkdir -p ${configDir}"
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
    hostPlatform = "aarch64-darwin";
  };

  environment.darwinConfig = "${repoRoot}/config/default.nix";

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
      set -g @catppuccin_flavour 'mocha'
      set -g @catppuccin_window_left_separator ""
      set -g @catppuccin_window_right_separator " "
      set -g @catppuccin_window_middle_separator " | "
      set -g @catppuccin_window_number_position "right"
      set -g @catppuccin_window_default_fill "none"
      set -g @catppuccin_window_current_fill "all"
      set -g @catppuccin_window_current_text "#{b:pane_current_path}"
      set -g @catppuccin_window_default_text "#{b:pane_current_path}"
      set -g @catppuccin_status_modules_right "application session"
      set -g @catppuccin_status_left_separator ""
      set -g @catppuccin_status_right_separator "█"
      set -g @catppuccin_status_right_separator_inverse "no"
      set -g @catppuccin_status_fill "icon"
      set -g @catppuccin_status_connect_separator "yes"
      set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M"
      set -g @catppuccin_session_text "#{?client_prefix,#S: prefix,#S: normal}"

      set -sg escape-time 0
      set-option -g default-shell "${systemZsh}"
      set-option -g default-command "exec ${systemZsh} -l"
      set-option -g focus-events on

      set -g default-terminal "alacritty"
      set-option -a terminal-overrides ",alacritty:RGB"

      run-shell ${catppuccinTmux}/share/tmux-plugins/catppuccin/catppuccin.tmux

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

  nix.settings = {
    max-jobs = 32;
    cores = 8;
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
