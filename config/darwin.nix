{ pkgs }:
{
  menuExtraClock = {
    FlashDateSeparators = false;
    Show24Hour = true;
    IsAnalog = false;
    ShowAMPM = false;
    ShowDate = 1;
    ShowDayOfMonth = false;
    ShowDayOfWeek = false;
    ShowSeconds = false;
  };

  NSGlobalDomain = {
    AppleEnableMouseSwipeNavigateWithScrolls = true;
    AppleEnableSwipeNavigateWithScrolls = true;
    AppleICUForce24HourTime = true;
    AppleMeasurementUnits = "Centimeters";
    AppleMetricUnits = 0;
    AppleFontSmoothing = 0;
    AppleScrollerPagingBehavior = true;
    ApplePressAndHoldEnabled = true;
    AppleShowAllFiles = true;
    AppleShowScrollBars = "WhenScrolling";
    AppleWindowTabbingMode = "fullscreen";
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticInlinePredictionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = true;
    NSDisableAutomaticTermination = true;
    NSDocumentSaveNewDocumentsToCloud = false;
    NSQuitAlwaysKeepsWindows = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    NSTextShowsControlCharacters = false;
    NSAutomaticWindowAnimationsEnabled = false;
    NSTableViewDefaultSizeMode = 1;
    NSUseAnimatedFocusRing = true;
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
    NSScrollAnimationEnabled = true;
    NSWindowShouldDragOnGesture = false;
    _HIHideMenuBar = false;
    "com.apple.keyboard.fnState" = true;
    "com.apple.sound.beep.feedback" = 0;
    "com.apple.sound.beep.volume" = 0.0;
    "com.apple.springing.enabled" = true;
    "com.apple.swipescrolldirection" = true;
    "com.apple.trackpad.enableSecondaryClick" = true;
  };
  dock = {
    appswitcher-all-displays = false;
    autohide = true;
    launchanim = true;
    magnification = false;
    mineffect = "genie";
    minimize-to-application = true;
    mru-spaces = false;
    orientation = "left";
    showAppExposeGestureEnabled = false;
    showDesktopGestureEnabled = false;
    showLaunchpadGestureEnabled = false;
    showMissionControlGestureEnabled = false;
    show-process-indicators = true;
    showhidden = false;
    static-only = false;
    tilesize = 40;
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
    show-recents = false;
  };
  finder = {
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    CreateDesktop = false;
    FXPreferredViewStyle = "clmv";
    QuitMenuItem = true;
    ShowPathbar = true;
    ShowStatusBar = true;
    FXDefaultSearchScope = "SCcf";
    _FXShowPosixPathInTitle = true;
    FXEnableExtensionChangeWarning = false;
  };
  trackpad = {
    ActuateDetents = true;
    ActuationStrength = 1;
    Clicking = true;
    Dragging = false;
    FirstClickThreshold = 1;
    ForceSuppressed = false;
    SecondClickThreshold = 1;
    TrackpadFourFingerPinchGesture = 0;
    TrackpadFourFingerVertSwipeGesture = 0;
    TrackpadMomentumScroll = true;
    TrackpadPinch = true;
    TrackpadRightClick = true;
    TrackpadRotate = true;
    TrackpadThreeFingerTapGesture = 2;
    TrackpadThreeFingerDrag = true;
    TrackpadThreeFingerVertSwipeGesture = 0;
    TrackpadTwoFingerDoubleTapGesture = false;
    TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
  };

  ActivityMonitor = {
    OpenMainWindow = true;
    ShowCategory = 100;
  };

  controlcenter = {
    BatteryShowPercentage = true;
    Bluetooth = true;
    Display = true;
    Sound = true;
  };

  LaunchServices = {
    LSQuarantine = false;
  };

  loginwindow = {
    autoLoginUser = null;
    DisableConsoleAccess = true;
    GuestEnabled = false;
    PowerOffDisabledWhileLoggedIn = false;
    RestartDisabled = false;
    RestartDisabledWhileLoggedIn = false;
    SHOWFULLNAME = false;
    ShutDownDisabled = false;
    ShutDownDisabledWhileLoggedIn = false;
    SleepDisabled = false;
    TALLogoutSavesState = false;
  };

  screensaver = {
    askForPassword = true;
    askForPasswordDelay = 180;
  };

  screencapture = {
    disable-shadow = false;
    include-date = true;
    save-selections = false;
    show-thumbnail = true;
    target = "file";
    type = "png";
  };

  SoftwareUpdate = {
    AutomaticallyInstallMacOSUpdates = false;
  };

  CustomUserPreferences = {
    NSGlobalDomain = {
      AppleSpacesSwitchOnActivate = false;
      NSRecentDocumentsLimit = 0;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
      forceLimitAdTracking = true;
    };
    "com.apple.Accessibility" = {
      CommandAndControlEnabled = false;
      SpeakThisEnabled = false;
    };
    "com.apple.airplay" = {
      showInMenuBarIfPresent = false;
    };
    "com.apple.assistant.support" = {
      "Assistant Enabled" = false;
    };
    "com.apple.HIToolbox" = {
      AppleDictationAutoEnable = false;
    };
    "com.apple.amp.mediasharingd" = {
      "home-sharing-enabled" = false;
      "photo-sharing-enabled" = false;
      "public-sharing-enabled" = false;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.finder" = {
      FXRemoveOldTrashItems = false;
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      WarnOnEmptyTrash = true;
      _FXEnableColumnAutoSizing = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
    };
    "com.apple.commerce" = {
      AutoUpdate = true;
      AutoUpdateRestartRequired = false;
    };
    "com.apple.ncprefs" = {
      content_visibility = 2;
    };
    "com.apple.preferences.sharing.SharingPrefsExtension" = {
      mediaSharingUIStatus = 0;
    };
    "com.apple.sharingd" = {
      DiscoverableMode = "Disabled";
    };
    "com.apple.Siri" = {
      StatusMenuVisible = false;
    };
    "com.apple.Spotlight" = {
      orderedItems = [
        {
          enabled = true;
          name = "APPLICATIONS";
        }
        {
          enabled = true;
          name = "MENU_EXPRESSION";
        }
        {
          enabled = false;
          name = "SYSTEM_PREFS";
        }
        {
          enabled = false;
          name = "DIRECTORIES";
        }
        {
          enabled = false;
          name = "PDF";
        }
        {
          enabled = false;
          name = "FONTS";
        }
        {
          enabled = false;
          name = "DOCUMENTS";
        }
        {
          enabled = false;
          name = "MESSAGES";
        }
        {
          enabled = false;
          name = "CONTACT";
        }
        {
          enabled = false;
          name = "EVENT_TODO";
        }
        {
          enabled = false;
          name = "IMAGES";
        }
        {
          enabled = false;
          name = "BOOKMARKS";
        }
        {
          enabled = false;
          name = "MUSIC";
        }
        {
          enabled = false;
          name = "MOVIES";
        }
        {
          enabled = false;
          name = "PRESENTATIONS";
        }
        {
          enabled = false;
          name = "SPREADSHEETS";
        }
        {
          enabled = false;
          name = "SOURCE";
        }
        {
          enabled = false;
          name = "MENU_DEFINITION";
        }
        {
          enabled = false;
          name = "MENU_CONVERSION";
        }
        {
          enabled = false;
          name = "MENU_OTHER";
        }
        {
          enabled = false;
          name = "MENU_WEBSEARCH";
        }
        {
          enabled = false;
          name = "MENU_SPOTLIGHT_SUGGESTIONS";
        }
      ];
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      AutomaticDownload = false;
      ConfigDataInstall = true;
      CriticalUpdateInstall = false;
    };
    "com.apple.suggestions" = {
      AppCanShowSiriSuggestionsBlacklist = [ "com.apple.Spotlight" ];
      SuggestionsAllowGeocode = false;
    };
    "~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd" = {
      ActivityAdvertisingAllowed = false;
      ActivityReceivingAllowed = false;
    };
    "com.apple.universalaccess" = {
      slowKey = false;
      slowKeyBeepOn = false;
      stickyKey = false;
      stickyKeyBeepOnModifier = false;
      stickyKeyShowWindow = false;
    };
  };

  CustomSystemPreferences = {
    "/Library/Application Support/CrashReporter/DiagnosticMessagesHistory" = {
      AutoSubmit = false;
      ThirdPartyDataSubmit = false;
    };
    "/Library/Preferences/com.apple.mDNSResponder" = {
      NoMulticastAdvertisements = true;
    };
    "/Library/Preferences/com.apple.AssetCache" = {
      Activated = false;
    };
  };

  hitoolbox = {
    AppleFnUsageType = "Change Input Source";
  };

  iCal = {
    "first day of week" = "Monday";
  };

  universalaccess = {
    closeViewScrollWheelToggle = false;
    closeViewZoomFollowsFocus = false;
    reduceMotion = false;
    reduceTransparency = false;
  };

  WindowManager = {
    EnableStandardClickToShowDesktop = false;
    EnableTilingByEdgeDrag = false;
    EnableTopTilingByEdgeDrag = false;
    EnableTilingOptionAccelerator = false;
    GloballyEnabled = false;
    StandardHideDesktopIcons = true;
    StandardHideWidgets = true;
  };
}
