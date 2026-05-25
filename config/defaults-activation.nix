{ config, lib, ... }:

with lib;

let
  cfg = config.system.defaults;
  primaryUser = config.system.primaryUser;
  userHome = "/Users/${primaryUser}";

  quotePlistString = value:
    "\"${replaceStrings [ "\\" "\"" "\n" "\r" "\t" ] [ "\\\\" "\\\"" "\\n" "\\r" "\\t" ] value}\"";

  plistLiteral = value:
    let
      valueType = builtins.typeOf value;
    in
    if valueType == "bool" then
      if value then "1" else "0"
    else if valueType == "int" || valueType == "float" then
      toString value
    else if valueType == "string" || valueType == "path" then
      quotePlistString (toString value)
    else if valueType == "list" then
      "(${concatStringsSep ", " (map plistLiteral value)})"
    else if valueType == "set" then
      "{ ${concatStringsSep " " (mapAttrsToList (name: nestedValue: "${quotePlistString name} = ${plistLiteral nestedValue};") value)} }"
    else
      throw "Unsupported defaults value type: ${valueType}";

  writeDefault = domain: key: value:
    let
      domainArg = escapeShellArg domain;
      keyArg = escapeShellArg key;
      valueType = builtins.typeOf value;
    in
    if valueType == "bool" then
      "/usr/bin/defaults write ${domainArg} ${keyArg} -bool ${if value then "true" else "false"}"
    else if valueType == "int" then
      "/usr/bin/defaults write ${domainArg} ${keyArg} -int ${toString value}"
    else if valueType == "float" then
      "/usr/bin/defaults write ${domainArg} ${keyArg} -float ${toString value}"
    else if valueType == "string" || valueType == "path" then
      "/usr/bin/defaults write ${domainArg} ${keyArg} -string ${escapeShellArg (toString value)}"
    else
      "/usr/bin/defaults write ${domainArg} ${keyArg} ${escapeShellArg (plistLiteral value)}";

  defaultsToList = domain: attrs:
    mapAttrsToList (key: value: writeDefault domain key value) (filterAttrs (_: value: value != null) attrs);

  normalizeUserDomain = domain:
    if domain == "NSGlobalDomain" then
      "-g"
    else if hasPrefix "~/" domain then
      "${userHome}/${removePrefix "~/" domain}"
    else
      domain;

  asPrimaryUser = command:
    ''launchctl asuser "$(id -u -- ${escapeShellArg primaryUser})" sudo -u ${escapeShellArg primaryUser} -- ${command}'';

  userDefaultsToList = domain: attrs:
    map asPrimaryUser (defaultsToList domain attrs);

  dockFiltered = builtins.removeAttrs cfg.dock [ "expose-group-by-app" ];

  loginwindow = defaultsToList "/Library/Preferences/com.apple.loginwindow" cfg.loginwindow;
  smb = defaultsToList "/Library/Preferences/SystemConfiguration/com.apple.smb.server" cfg.smb;
  softwareUpdate = defaultsToList "/Library/Preferences/com.apple.SoftwareUpdate" cfg.SoftwareUpdate;
  customSystemPreferences =
    flatten (mapAttrsToList (domain: value: defaultsToList domain value) cfg.CustomSystemPreferences);

  globalPreferences = userDefaultsToList ".GlobalPreferences" cfg.".GlobalPreferences";
  launchServices = userDefaultsToList "com.apple.LaunchServices" cfg.LaunchServices;
  nsGlobalDomain = userDefaultsToList "-g" cfg.NSGlobalDomain;
  menuExtraClock = userDefaultsToList "com.apple.menuextra.clock" cfg.menuExtraClock;
  dock = userDefaultsToList "com.apple.dock" dockFiltered;
  finder = userDefaultsToList "com.apple.finder" cfg.finder;
  hitoolbox = userDefaultsToList "com.apple.HIToolbox" cfg.hitoolbox;
  iCal = userDefaultsToList "com.apple.iCal" cfg.iCal;
  magicmouse = userDefaultsToList "com.apple.AppleMultitouchMouse" cfg.magicmouse;
  magicmouseBluetooth = userDefaultsToList "com.apple.driver.AppleMultitouchMouse.mouse" cfg.magicmouse;
  screencapture = userDefaultsToList "com.apple.screencapture" cfg.screencapture;
  screensaver = userDefaultsToList "com.apple.screensaver" cfg.screensaver;
  spaces = userDefaultsToList "com.apple.spaces" cfg.spaces;
  trackpad = userDefaultsToList "com.apple.AppleMultitouchTrackpad" cfg.trackpad;
  trackpadBluetooth = userDefaultsToList "com.apple.driver.AppleBluetoothMultitouch.trackpad" cfg.trackpad;
  universalaccess = userDefaultsToList "com.apple.universalaccess" cfg.universalaccess;
  activityMonitor = userDefaultsToList "com.apple.ActivityMonitor" cfg.ActivityMonitor;
  windowManager = userDefaultsToList "com.apple.WindowManager" cfg.WindowManager;
  controlcenter =
    userDefaultsToList "${userHome}/Library/Preferences/ByHost/com.apple.controlcenter" cfg.controlcenter;
  customUserPreferences =
    flatten (mapAttrsToList (domain: value: userDefaultsToList (normalizeUserDomain domain) value) cfg.CustomUserPreferences);
in
{
  config = {
    system.activationScripts.defaults.text = mkForce ''
      echo >&2 "system defaults..."
      ${concatStringsSep "\n" loginwindow}
      ${concatStringsSep "\n" smb}
      ${concatStringsSep "\n" softwareUpdate}
      ${concatStringsSep "\n" customSystemPreferences}
    '';

    system.activationScripts.userDefaults.text = mkForce ''
      echo >&2 "user defaults..."
      ${concatStringsSep "\n" nsGlobalDomain}
      ${concatStringsSep "\n" globalPreferences}
      ${concatStringsSep "\n" launchServices}
      ${concatStringsSep "\n" menuExtraClock}
      ${concatStringsSep "\n" dock}
      ${concatStringsSep "\n" finder}
      ${concatStringsSep "\n" hitoolbox}
      ${concatStringsSep "\n" iCal}
      ${concatStringsSep "\n" magicmouse}
      ${concatStringsSep "\n" magicmouseBluetooth}
      ${concatStringsSep "\n" screencapture}
      ${concatStringsSep "\n" screensaver}
      ${concatStringsSep "\n" spaces}
      ${concatStringsSep "\n" trackpad}
      ${concatStringsSep "\n" trackpadBluetooth}
      ${concatStringsSep "\n" universalaccess}
      ${concatStringsSep "\n" activityMonitor}
      ${concatStringsSep "\n" customUserPreferences}
      ${concatStringsSep "\n" windowManager}
      ${concatStringsSep "\n" controlcenter}
      ${optionalString (dock != [ ]) ''
        echo >&2 "restarting Dock..."
        killall -qu ${escapeShellArg primaryUser} Dock || true
      ''}
    '';
  };
}
