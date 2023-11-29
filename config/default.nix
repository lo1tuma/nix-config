{  pkgs, ... }:

let
  inherit (pkgs) zsh;
  coc = import ../dotfiles/coc.nix;
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
in {
  environment.etc = {
    "per-user/alacritty/alacritty.yml".text = import ../dotfiles/alacritty.nix { inherit zsh; };
    "per-user/.gitconfig".text = import ../dotfiles/gitconfig.nix {};
    "per-user/.gitignore".text = import ../dotfiles/gitignore.nix {};
    "per-user/.npmrc".text = import ../dotfiles/npmrc.nix {};
    "per-user/coc-settings.json".text = builtins.toJSON (coc {});
  };
  system.activationScripts.extraUserActivation.text = ''
    ln -sfn /etc/per-user/alacritty ~/.config/
    ln -sfn /etc/per-user/.gitconfig ~/
    ln -sfn /etc/per-user/.gitignore ~/
    ln -sfn /etc/per-user/.npmrc ~/
    mkdir -p ~/.config/nvim/
    ln -sfn /etc/per-user/coc-settings.json ~/.config/nvim/
  '';
  environment.shells = [ pkgs.zsh ];
  environment.loginShell = "${pkgs.zsh}/bin/zsh --login";
  environment.variables = rec {
    SHELL = "${pkgs.zsh}/bin/zsh";
    LANG = "en_US.UTF-8";
    LC_ALL = LANG;
    LESSCHARSET = "utf-8";
  };
  system.defaults = import ./darwin.nix { inherit pkgs; };
  environment.systemPackages = import ./packages.nix { inherit pkgs; };

  nixpkgs = {
    config = { allowUnfree = true; allowBroken = false; };
  };

  environment.darwinConfig = "$HOME/projects/nix-config/config/default.nix";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
    promptInit = ''
      eval "$(starship init zsh)"
    '';
    interactiveShellInit = ''
      autoload -U up-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      zle -N up-line-or-beginning-search
      HISTSIZE=10000000
      SAVEHIST=10000000
      alias npm="node --dns-result-order=ipv4first $(which npm)"
      alias git="git config --unset --local core.hooksPath; git"
    '';
  };

  programs.tmux = {
    enable = true;
    defaultCommand = "${zsh}/bin/zsh";
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
      set-option -g default-shell "${zsh}/bin/zsh"
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
      bind-key C-g display-popup -E -d "#{pane_current_path}" -xC -yC -w 80% -h 75% "git status && ${zsh}/bin/zsh -i"
    '';
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;

  fonts = {
    fonts = [ pkgs.nerdfonts ];
    fontDir = {
        enable = true;
    };
  };

  nix.settings = {
      max-jobs = 32;
      cores = 8;
      auto-optimise-store = true;
  };
  services.nix-daemon.enable = true;
}
