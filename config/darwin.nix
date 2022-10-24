{ pkgs }:
{
  NSGlobalDomain = {
    AppleFontSmoothing = 0;
    AppleKeyboardUIMode = 3;
    ApplePressAndHoldEnabled = true;
    InitialKeyRepeat = 25;
    KeyRepeat = 2;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    "com.apple.trackpad.enableSecondaryClick" = true;
  };
  dock = {
    autohide = true;
    orientation = "left";
    tilesize = 40;
    show-recents = false;
  };
  finder = {
    AppleShowAllExtensions = true;
    QuitMenuItem = true;
    _FXShowPosixPathInTitle = true;
    FXEnableExtensionChangeWarning = false;
  };
  trackpad = {
    Clicking = true;
    TrackpadRightClick = false;
    TrackpadThreeFingerDrag = false;
  };

}
