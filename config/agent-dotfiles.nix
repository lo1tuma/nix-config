{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  primaryUser = config.system.primaryUser;
  primaryGroup = "staff";
  managedOwner = "${primaryUser}:${primaryGroup}";
  homeDir = "/Users/${primaryUser}";
  sourceRoot = ../dotfiles/ai-agents;
  instructionsSource = sourceRoot + "/AGENTS.md";
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

  mapFilesToTarget =
    targetPrefix:
    lib.mapAttrs' (relativePath: source: lib.nameValuePair "${targetPrefix}/${relativePath}" source);

  managedLinkedFiles =
    {
      ".claude/CLAUDE.md" = instructionsSource;
      ".codex/agents.md" = instructionsSource;
    };

  managedCopiedFiles =
    mapFilesToTarget ".claude/skills" managedSkillFiles
    // mapFilesToTarget ".codex/skills" managedSkillFiles;

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
        /bin/cp ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg tmpPath}
        /bin/mv ${lib.escapeShellArg tmpPath} ${lib.escapeShellArg targetPath}
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
        codexDesired=${lib.escapeShellArg ''project_doc_fallback_filenames = ["AGENTS.md", "agents.md"]''}
        if [ -e "$codexConfig" ]; then
          /usr/sbin/chown ${lib.escapeShellArg managedOwner} "$codexConfig"
          /usr/bin/sudo -u ${lib.escapeShellArg primaryUser} /bin/sh -c ${lib.escapeShellArg ''
            /usr/bin/awk -v desired="$1" '
              /^project_doc_fallback_filenames[[:space:]]*=/ { print desired; seen = 1; next }
              { print }
              END {
                if (!seen) {
                  if (NR > 0) {
                    print ""
                  }
                  print desired
                }
              }
            ' "$2" > "$3"
          ''} dummy "$codexDesired" "$codexConfig" "$codexTmp"
          /bin/mv "$codexTmp" "$codexConfig"
          /usr/sbin/chown ${lib.escapeShellArg managedOwner} "$codexConfig"
        else
          /usr/bin/sudo -u ${lib.escapeShellArg primaryUser} /bin/sh -c ${lib.escapeShellArg ''
            printf '%s\n' 'project_doc_fallback_filenames = ["AGENTS.md", "agents.md"]' > "$1"
          ''} dummy "$codexConfig"
        fi
      ''
    ]
    ++ lib.mapAttrsToList linkFile managedLinkedFiles
    ++ lib.mapAttrsToList copyFile managedCopiedFiles;
in
{
  system.activationScripts.postActivation.text = lib.mkAfter (
    lib.concatStringsSep "\n" activationCommands
  );
}
