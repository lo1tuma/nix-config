{ config, pkgs, ... }:

let
  lib = pkgs.lib;
  homeDir = "/Users/${config.system.primaryUser}";
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

  managedFiles =
    {
      ".claude/CLAUDE.md" = instructionsSource;
      ".codex/agents.md" = instructionsSource;
    }
    // mapFilesToTarget ".claude/skills" managedSkillFiles
    // mapFilesToTarget ".codex/skills" managedSkillFiles;

  ensureDirectory = relativePath: "mkdir -p ${lib.escapeShellArg "${homeDir}/${relativePath}"}";

  linkFile =
    relativePath: source:
    let
      targetPath = "${homeDir}/${relativePath}";
    in
    ''
      mkdir -p ${lib.escapeShellArg (builtins.dirOf targetPath)}
      ln -sfn ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg targetPath}
    '';

  activationCommands =
    [
      (ensureDirectory ".claude")
      (ensureDirectory ".claude/skills")
      (ensureDirectory ".codex")
      (ensureDirectory ".codex/skills")
      ''
        codexConfig=${lib.escapeShellArg "${homeDir}/.codex/config.toml"}
        codexDesired='project_doc_fallback_filenames = ["AGENTS.md", "agents.md"]'
        codexTmp="$codexConfig.nix-config.tmp"
        if [ -f "$codexConfig" ]; then
          if /usr/bin/grep -q '^project_doc_fallback_filenames[[:space:]]*=' "$codexConfig"; then
            /usr/bin/awk -v desired="$codexDesired" '
              /^project_doc_fallback_filenames[[:space:]]*=/ { print desired; next }
              { print }
            ' "$codexConfig" > "$codexTmp"
            /bin/mv "$codexTmp" "$codexConfig"
          else
            /bin/printf '\n%s\n' "$codexDesired" >> "$codexConfig"
          fi
        else
          /bin/printf '%s\n' "$codexDesired" > "$codexConfig"
        fi
      ''
    ]
    ++ lib.mapAttrsToList linkFile managedFiles;
in
{
  system.activationScripts.postActivation.text = lib.mkAfter (
    lib.concatStringsSep "\n" activationCommands
  );
}
