{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  primaryUser = config.system.primaryUser;
  primaryGroup = "staff";
  managedOwner = "${primaryUser}:${primaryGroup}";
  homeDir = "/Users/${primaryUser}";
  sourceRoot = ../dotfiles/ai-agents;
  instructionsSource = sourceRoot + "/AGENTS.md";
  claudeSettingsSource = sourceRoot + "/claude-settings.json";
  skillsSource = sourceRoot + "/skills";

  isVisibleEntry = name: builtins.substring 0 1 name != ".";

  collectFiles =
    dir: prefix:
    let
      entries = lib.filterAttrs (name: _: isVisibleEntry name) (builtins.readDir dir);
      collectEntry =
        name: type:
        let
          childPath = dir + "/${name}";
          relativePath = if prefix == "" then name else "${prefix}/${name}";
        in
        if type == "directory" then
          collectFiles childPath relativePath
        else
          { "${relativePath}" = childPath; };
    in
    lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList collectEntry entries);

  managedSkillFiles =
    if builtins.pathExists skillsSource then
      collectFiles skillsSource ""
    else
      { };

  pstackRevision = "6ed0f7a9504f577d7529064103cecce9be7dfc5e";

  pstackFile =
    path: sha256:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/cursor/plugins/${pstackRevision}/pstack/${path}";
      inherit sha256;
    };

  pstackLicense = pstackFile "LICENSE" "03i0gfkks9vl2q35gw3wwz34gqh2bq88s0hsd9b949z0psk7r5dw";

  pstackSkills = {
    unslop = {
      sha256 = "1jh0hqjdxndlgi1mkjk6nklr1114kag0c88r44la8cyrjhi5gln6";
      displayName = "Unslop";
      shortDescription = "Cut AI tells from any writing";
      defaultPrompt = "Use $unslop to strip AI writing patterns from this text.";
    };
    technical-writing = {
      sha256 = "0k5qz0k93fxb7kpdaxm7rim7qg90v5pyp3fz6s7yw4p4b9i9wvbd";
      displayName = "Technical Writing";
      shortDescription = "Write docs a tired engineer gets first read";
      defaultPrompt = "Use $technical-writing to write or review this document.";
    };
  };

  codexDescriptor =
    name: skill:
    pkgs.writeText "${name}-openai.yaml" ''
      interface:
        display_name: "${skill.displayName}"
        short_description: "${skill.shortDescription}"
        default_prompt: "${skill.defaultPrompt}"

      policy:
        allow_implicit_invocation: false
    '';

  pstackSkillFiles = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList (name: skill: {
      "${name}/SKILL.md" = pstackFile "skills/${name}/SKILL.md" skill.sha256;
      "${name}/LICENSE" = pstackLicense;
      "${name}/agents/openai.yaml" = codexDescriptor name skill;
    }) pstackSkills
  );

  skillFiles = managedSkillFiles // pstackSkillFiles;

  mapFilesToTarget =
    targetPrefix:
    lib.mapAttrs' (relativePath: source: lib.nameValuePair "${targetPrefix}/${relativePath}" source);

  managedLinkedFiles =
    {
      ".claude/CLAUDE.md" = instructionsSource;
      ".codex/agents.md" = instructionsSource;
    };

  managedCopiedFiles =
    {
      ".claude/settings.json" = claudeSettingsSource;
    }
    // mapFilesToTarget ".claude/skills" skillFiles
    // mapFilesToTarget ".codex/skills" skillFiles;

  runAsPrimaryUser = command: "/usr/bin/sudo -u ${lib.escapeShellArg primaryUser} /bin/sh -c ${lib.escapeShellArg command}";

  ensureDirectory =
    relativePath:
    let
      targetPath = "${homeDir}/${relativePath}";
    in
    ''
      if [ -e ${lib.escapeShellArg targetPath} ]; then
        /usr/sbin/chown ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetPath}
      fi
      ${runAsPrimaryUser "mkdir -p ${lib.escapeShellArg targetPath}"}
    '';

  linkFile =
    relativePath: source:
    let
      targetPath = "${homeDir}/${relativePath}";
    in
    ''
      if [ -e ${lib.escapeShellArg (builtins.dirOf targetPath)} ]; then
        /usr/sbin/chown ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg (builtins.dirOf targetPath)}
      fi
      if [ -L ${lib.escapeShellArg targetPath} ] || [ -e ${lib.escapeShellArg targetPath} ]; then
        /usr/sbin/chown -h ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetPath} 2>/dev/null || true
      fi
      ${runAsPrimaryUser ''
        mkdir -p ${lib.escapeShellArg (builtins.dirOf targetPath)}
        ln -sfn ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg targetPath}
      ''}
    '';

  copyFile =
    relativePath: source:
    let
      targetPath = "${homeDir}/${relativePath}";
      targetDir = builtins.dirOf targetPath;
      tmpPath = "${targetPath}.nix-config.tmp";
    in
    ''
      if [ -e ${lib.escapeShellArg targetDir} ]; then
        /usr/sbin/chown ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetDir}
      fi
      if [ -L ${lib.escapeShellArg targetPath} ] || [ -e ${lib.escapeShellArg targetPath} ]; then
        /usr/sbin/chown -h ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetPath} 2>/dev/null || true
      fi
      ${runAsPrimaryUser ''
        mkdir -p ${lib.escapeShellArg targetDir}
        rm -f ${lib.escapeShellArg tmpPath}
        /bin/cp -f ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg tmpPath}
        /bin/mv -f ${lib.escapeShellArg tmpPath} ${lib.escapeShellArg targetPath}
      ''}
    '';

  activationCommands =
    [
      (ensureDirectory ".claude")
      (ensureDirectory ".claude/skills")
      (ensureDirectory ".codex")
      (ensureDirectory ".codex/skills")
      ''
        codexConfig=${lib.escapeShellArg "${homeDir}/.codex/config.toml"}
        codexTmp="$codexConfig.nix-config.tmp"
        codexProjectDocs=${lib.escapeShellArg ''project_doc_fallback_filenames = ["AGENTS.md", "agents.md"]''}
        codexDefaultModeRequestUserInput=${lib.escapeShellArg ''default_mode_request_user_input = true''}
        if [ -e "$codexConfig" ]; then
          /usr/sbin/chown ${lib.escapeShellArg managedOwner} "$codexConfig"
          /usr/bin/sudo -u ${lib.escapeShellArg primaryUser} /bin/sh -c ${lib.escapeShellArg ''
            /usr/bin/awk -v projectDocs="$1" -v defaultModeRequestUserInput="$2" '
              function leaveFeatures() {
                if (inFeatures && !seenDefaultModeRequestUserInput) {
                  print defaultModeRequestUserInput
                }
                inFeatures = 0
              }

              /^project_doc_fallback_filenames[[:space:]]*=/ { print projectDocs; seenProjectDocs = 1; next }

              /^\[[^]]+\][[:space:]]*$/ {
                leaveFeatures()
                inFeatures = ($0 == "[features]")
                if (inFeatures) {
                  seenFeatures = 1
                }
                print
                next
              }

              inFeatures && /^default_mode_request_user_input[[:space:]]*=/ {
                print defaultModeRequestUserInput
                seenDefaultModeRequestUserInput = 1
                next
              }

              { print }
              END {
                leaveFeatures()
                if (!seenProjectDocs) {
                  if (NR > 0) {
                    print ""
                  }
                  print projectDocs
                }
                if (!seenFeatures) {
                  print ""
                  print "[features]"
                  print defaultModeRequestUserInput
                }
              }
            ' "$3" > "$4"
          ''} dummy "$codexProjectDocs" "$codexDefaultModeRequestUserInput" "$codexConfig" "$codexTmp"
          /bin/mv -f "$codexTmp" "$codexConfig"
          /usr/sbin/chown ${lib.escapeShellArg managedOwner} "$codexConfig"
        else
          /usr/bin/sudo -u ${lib.escapeShellArg primaryUser} /bin/sh -c ${lib.escapeShellArg ''
            printf '%s\n\n%s\n%s\n' "$1" '[features]' "$2" > "$3"
          ''} dummy "$codexProjectDocs" "$codexDefaultModeRequestUserInput" "$codexConfig"
        fi
      ''
    ]
    ++ lib.mapAttrsToList linkFile managedLinkedFiles
    ++ lib.mapAttrsToList copyFile managedCopiedFiles;
in
{
  system.activationScripts.postActivation.text = lib.mkBefore (
    lib.concatStringsSep "\n" activationCommands
  );
}
