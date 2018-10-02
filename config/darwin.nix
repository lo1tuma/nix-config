{ pkgs }:
{
  NSGlobalDomain = {
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
  };
  dock = {
    autohide = true;
    orientation = "left";
    tilesize = 40;
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
