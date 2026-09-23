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
  skillLibraryDirectory = ".agent-skill-library";
  retiredSkillNames = [ "security-audit" ];

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
      tier = "entry";
      referenceFiles = { };
      allowImplicitInvocation = false;
      displayName = "Unslop";
      shortDescription = "Cut AI tells from any writing";
      defaultPrompt = "Use $unslop to strip AI writing patterns from this text.";
    };
    technical-writing = {
      sha256 = "0k5qz0k93fxb7kpdaxm7rim7qg90v5pyp3fz6s7yw4p4b9i9wvbd";
      tier = "entry";
      referenceFiles = { };
      allowImplicitInvocation = false;
      displayName = "Technical Writing";
      shortDescription = "Write docs a tired engineer gets first read";
      defaultPrompt = "Use $technical-writing to write or review this document.";
    };
    principle-type-system-discipline = {
      sha256 = "0ph2785dfsf2kpymi0bx5g58ynaryrhy5lrh010qck7v3w1shgf8";
      tier = "lens";
      referenceFiles = { };
      allowImplicitInvocation = false;
      displayName = "Type System Discipline";
      shortDescription = "Make illegal states unrepresentable";
      defaultPrompt = "Use $principle-type-system-discipline to review these types and signatures.";
    };
    typescript-best-practices = {
      sha256 = "0phcni266lxdzbi3kdm5ys4fkw6ghcs36vs7qprzc1g220bydy98";
      tier = "entry";
      referenceFiles = {
        "references/patterns.md" = "113kf3z0qxvh4laaypkxmm41mqyw4an9ld6is0snl1pss8rcvsb2";
      };
      allowImplicitInvocation = false;
      displayName = "TypeScript Best Practices";
      shortDescription = "Model TypeScript with unions, brands and boundaries";
      defaultPrompt = "Use $typescript-best-practices while editing this TypeScript code.";
    };
    principle-model-the-domain = {
      sha256 = "01xc9q76pp6l6sp4nglr23n5hh5rbrk4bbl2wxv3zb1zfadbpbdv";
      tier = "lens";
      referenceFiles = { };
      allowImplicitInvocation = false;
      displayName = "Model the Domain";
      shortDescription = "Encode the domain in structure, not conditionals";
      defaultPrompt = "Use $principle-model-the-domain to restructure this branching logic.";
    };
    no-comments = {
      sha256 = "019bzvylwqj516grh5zpx89v0s1wg5x2pi90jwx4qw3x5610hnsw";
      tier = "entry";
      referenceFiles = { };
      allowImplicitInvocation = false;
      displayName = "No Comments";
      shortDescription = "Delete comments and fix what they were hiding";
      defaultPrompt = "Use $no-comments on the current diff.";
    };
  };

  pstackAgents = {
    comment-sicko = {
      sha256 = "10kw3z81z2v5zg1dbj6igbw44b6n0y87phgsik3mz94d021h7zf0";
    };
  };

  githubSkillSources = {
    scrutineer = {
      owner = "alpha-omega-security";
      repo = "scrutineer";
      rev = "8ef40fe684aebcc6917fe0de9546947e74e837ab";
      sha256 = "180ii46jlc4xsynj2wz0hqjsjif0k8zwcv2vm384gsm45n9dcjfi";
      licenseFile = "LICENSE";
      skills = {
        threat-model = {
          path = "skills/threat-model";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Threat Model";
          shortDescription = "Trust boundaries and an entry-point trust table";
          defaultPrompt = "Use $threat-model to build the trust map for this codebase.";
        };
        audit-authz = {
          path = "skills/audit-authz";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Audit Authorization";
          shortDescription = "Hunt broken access control, IDOR and tenant leaks";
          defaultPrompt = "Use $audit-authz to audit authorization in this codebase.";
        };
        audit-injection = {
          path = "skills/audit-injection";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Audit Injection";
          shortDescription = "Hunt shell, query, deserialization and template injection";
          defaultPrompt = "Use $audit-injection to audit injection sinks in this codebase.";
        };
        audit-exfil = {
          path = "skills/audit-exfil";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Audit Exfiltration";
          shortDescription = "Hunt SSRF, path traversal and data disclosure";
          defaultPrompt = "Use $audit-exfil to audit exfiltration paths in this codebase.";
        };
        critic = {
          path = "skills/critic";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Finding Critic";
          shortDescription = "Judge whether a finding reaches production";
          defaultPrompt = "Use $critic to judge the production viability of these findings.";
        };
      };
    };
    security-check = {
      owner = "ersinkoc";
      repo = "security-check";
      rev = "80d68f68da642f65883ca1791f03fb3ceaf456d5";
      sha256 = "19bh8p5y3sn9qg9l8mi5a706lp4ff9pxm6lr9jx5h48mdmy2pga4";
      licenseFile = "LICENSE";
      skills = {
        sc-lang-typescript = {
          path = "skills/sc-lang-typescript";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "TypeScript Attack Patterns";
          shortDescription = "TypeScript and Node attack patterns with safe forms";
          defaultPrompt = "Use $sc-lang-typescript to hunt TypeScript and Node vulnerability patterns.";
        };
        sc-verifier = {
          path = "skills/sc-verifier";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Finding Verifier";
          shortDescription = "Confirm, reject or hold a security finding";
          defaultPrompt = "Use $sc-verifier to verify these security findings.";
        };
      };
    };
    superagent-skills = {
      owner = "superagent-ai";
      repo = "skills";
      rev = "0da315b873ed141025fa601ed6e0ebe0c878d5af";
      sha256 = "17hbzpy620cbh23bl7zck059pq9j6jyyn3s6h4kvwn3lsmlvvqxd";
      licenseFile = "LICENSE";
      skills = {
        ci-cd-security = {
          path = "skills/ci-cd-security";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "CI/CD Security";
          shortDescription = "Audit workflow triggers, permissions and untrusted input";
          defaultPrompt = "Use $ci-cd-security to audit the CI pipelines in this repository.";
        };
        supply-chain-security = {
          path = "skills/supply-chain-security";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Supply Chain Security";
          shortDescription = "Audit dependency identity and install-time behavior";
          defaultPrompt = "Use $supply-chain-security to audit the dependencies of this project.";
        };
      };
    };
    secskills = {
      owner = "trilwu";
      repo = "secskills";
      rev = "ca53957bcd8e3b83b5d4d190bb3ad008a4f15c84";
      sha256 = "1gi9w9sl7j5vppvkld9bcnl5wyxjb8wiwl4zfy0f7ywngphm2mw1";
      licenseFile = "LICENSE";
      skills = {
        orchestrating-vulnerability-research = {
          path = "secskills-core/skills/orchestrating-vulnerability-research";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Vulnerability Research Loop";
          shortDescription = "Decompose, hunt, refute and reconcile across agents";
          defaultPrompt = "Use $orchestrating-vulnerability-research to run a multi-agent hunt against this target.";
        };
      };
    };
    cloudflare-security-audit = {
      owner = "cloudflare";
      repo = "security-audit-skill";
      rev = "c1c8a8c1471069fb0e188eeaff69b8e8db6564a8";
      sha256 = "1lyw9z750lsgywfkvif6rphjv8ar6bzi1c81jpjpp41d78540md1";
      licenseFile = "LICENSE";
      skills = {
        security-attack-classes = {
          path = "skills/security-audit";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Security Attack Classes";
          shortDescription = "Per-surface attack-class lenses with validation rules";
          defaultPrompt = "Use $security-attack-classes to pick the attack classes that apply to this component.";
        };
      };
    };
    trailofbits-skills = {
      owner = "trailofbits";
      repo = "skills";
      rev = "32e34f8173796e3566a51aee877dc96bc5191f64";
      sha256 = "1dwmjg1qscz9c8n0n6nrql1pivrp28zcqvfjc6yf61fbh1p4rjgh";
      licenseFile = "LICENSE";
      skills = {
        fp-check = {
          path = "plugins/fp-check/skills/fp-check";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "False Positive Check";
          shortDescription = "Gate a candidate finding before it is reported";
          defaultPrompt = "Use $fp-check to decide whether this finding is real.";
        };
        vulnerability-triage-brocards = {
          path = "plugins/vulnerability-triage-brocards/skills/vulnerability-triage-brocards";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Triage Brocards";
          shortDescription = "Falsifiable tests that dismiss a weak finding";
          defaultPrompt = "Use $vulnerability-triage-brocards to filter these candidate findings.";
        };
      };
    };
    pproenca-dot-skills = {
      owner = "pproenca";
      repo = "dot-skills";
      rev = "cf93c57cac89d6fc3e4194686000411567f5caf3";
      sha256 = "1l1g5jpa002s7s3qsbk6rivn70qzh1yqargzy8x97z5spixvr0jq";
      licenseFile = "LICENSE";
      skills = {
        same-results-less-code = {
          path = "skills/.experimental/same-results-less-code";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Same Results, Less Code";
          shortDescription = "Spot hidden duplication and wrong abstractions";
          defaultPrompt = "Use $same-results-less-code to find duplicated meaning and accidental volume in this code.";
        };
        implementation-functional-patterns = {
          path = "skills/.curated/implementation-functional-patterns";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Functional Patterns";
          shortDescription = "Functional TypeScript forms of the GoF patterns";
          defaultPrompt = "Use $implementation-functional-patterns to replace this class hierarchy with idiomatic TypeScript.";
        };
        implementation-design-patterns = {
          path = "skills/.curated/implementation-design-patterns";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Design Patterns, Class Forms";
          shortDescription = "GoF class forms in TypeScript, and how to choose between them";
          defaultPrompt = "Use $implementation-design-patterns when the right answer to this design problem is a class.";
        };
      };
    };
    recyclarr = {
      owner = "recyclarr";
      repo = "recyclarr";
      rev = "9a43f26aae4eee31f579cc037bd6e4029c827033";
      sha256 = "1nkwbvhrw7014rl9abifhgxdbpjxkdzxs5wq4zwj10kjck7sqrs7";
      licenseFile = "LICENSE";
      skills = {
        duplication-vs-abstraction = {
          path = ".opencode/skills/duplication-vs-abstraction";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Duplication vs Abstraction";
          shortDescription = "Decide whether to extract or keep the duplication";
          defaultPrompt = "Use $duplication-vs-abstraction to decide whether this duplication should become a shared abstraction.";
        };
      };
    };
    el-feo-ai-context = {
      owner = "el-feo";
      repo = "ai-context";
      rev = "ae77f01b54c90589d8a16bbeb1afadd2f6fbd2fc";
      sha256 = "0dcv9hhcv16gv16ka9zasmcgpqnhl46i21kmhcqp4n059zbgfayv";
      licenseFile = "LICENSE";
      skills = {
        fowler = {
          path = "plugins/fowler/skills/fowler";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Fowler Refactoring";
          shortDescription = "Refactor with the mechanics of Fowler's catalog";
          defaultPrompt = "Use $fowler to diagnose smells and refactor this code in small verified steps.";
        };
      };
    };
    tslateman-skills = {
      owner = "tslateman";
      repo = "skills";
      rev = "d232bb89a5debe02fc689cd1bf614a0849d3f215";
      sha256 = "061xizg3xxsw075xliv0w527n0c1d2gi0dp3caynl2bi1fhphnw2";
      licenseFile = "LICENSE";
      skills = {
        tidy = {
          path = "skills/craft/tidy";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Tidy First";
          shortDescription = "Decide if and when a small cleanup pays";
          defaultPrompt = "Use $tidy to decide whether to tidy this code first, after, later or never.";
        };
      };
    };
    nodatime = {
      owner = "nodatime";
      repo = "nodatime";
      rev = "7f36cf37ba0181eaec0074ee118ca0d1cf8b3090";
      sha256 = "01n1sk6z0f23r5h5bpkyah8vhz73hdzm10l78qbflys1gfbc1qv6";
      licenseFile = "LICENSE.txt";
      skills = {
        gof-patterns = {
          path = ".claude/skills/gof-patterns";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "GoF Patterns";
          shortDescription = "Choose a design pattern in TypeScript, or none";
          defaultPrompt = "Use $gof-patterns to decide which pattern, if any, fits this problem.";
        };
      };
    };
    kayaman-skills = {
      owner = "kayaman";
      repo = "skills";
      rev = "99442206526922bb8cb859d167de06e3e96d95a2";
      sha256 = "1hfgr8dfshs7ax0bn4rk4iihnlf4rh0ipzmcw2jlgz6jgz801mb2";
      licenseFile = "LICENSE";
      skills = {
        design-patterns = {
          path = "design-patterns";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Design Patterns";
          shortDescription = "Pattern selection with when-not-to rules";
          defaultPrompt = "Use $design-patterns to judge whether a pattern is justified here.";
        };
      };
    };
    steve-skill-market = {
      owner = "StevenACoffman";
      repo = "steve-skill-market";
      rev = "fde6536923248d86e101899c88fd1037de94f727";
      sha256 = "1380c0drk5spd5mv7fary45wzylhr4s8dzwrvxvagh471yhvnn7g";
      licenseFile = "LICENSE";
      skills = {
        somewhat-general-purpose-interface = {
          path = "skills/somewhat-general-purpose-interface";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "General-Purpose Interface";
          shortDescription = "Find the somewhat general interface";
          defaultPrompt = "Use $somewhat-general-purpose-interface to review this module's interface.";
        };
        pull-complexity-downward = {
          path = "skills/pull-complexity-downward";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Pull Complexity Downward";
          shortDescription = "Absorb complexity instead of exporting it";
          defaultPrompt = "Use $pull-complexity-downward to decide which decisions this module should absorb.";
        };
        define-errors-out-of-existence = {
          path = "skills/define-errors-out-of-existence";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Define Errors Out of Existence";
          shortDescription = "Remove exceptions by redefining semantics";
          defaultPrompt = "Use $define-errors-out-of-existence to review this error handling.";
        };
        information-hiding-temporal-decomposition = {
          path = "skills/information-hiding-temporal-decomposition";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Information Hiding";
          shortDescription = "Hide decisions, avoid temporal decomposition";
          defaultPrompt = "Use $information-hiding-temporal-decomposition to find leaked decisions in these modules.";
        };
        pass-through-method-wrong-layer-count = {
          path = "skills/pass-through-method-wrong-layer-count";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Pass-Through Methods";
          shortDescription = "Remove layers that add no abstraction";
          defaultPrompt = "Use $pass-through-method-wrong-layer-count to audit these layers.";
        };
        design-it-twice = {
          path = "skills/design-it-twice";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Design It Twice";
          shortDescription = "Compare two designs before committing";
          defaultPrompt = "Use $design-it-twice before implementing this design.";
        };
      };
    };
    hudrazine-skills = {
      owner = "hudrazine";
      repo = "skills";
      rev = "6284e4f5e903687221350136c4a4e491fdb14548";
      sha256 = "1a5s9f5gy465bq55zxynanbp1gbxzcqj11jil0zi2kwr0mwimqk0";
      licenseFile = "LICENSE";
      skills = {
        design-deep-modules = {
          path = "skills/design-deep-modules";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Design Deep Modules";
          shortDescription = "Preserve, deepen, merge, split or delay a boundary";
          defaultPrompt = "Use $design-deep-modules to decide the move for this module boundary.";
        };
      };
    };
    clairvoyance = {
      owner = "codybrom";
      repo = "clairvoyance";
      rev = "b11ca9349436fb7afd891a999d07d6d1a15b348b";
      sha256 = "11dl9j8n2ky54fcynf7g2mxpb27x9qmh3wgk5ij6h8yj8pbhflv2";
      licenseFile = "LICENSE";
      skills = {
        error-design = {
          path = "skills/error-design";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Error Design";
          shortDescription = "Define out, mask, aggregate or propagate errors";
          defaultPrompt = "Use $error-design to review the error handling in this code.";
        };
        general-vs-special = {
          path = "skills/general-vs-special";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "General vs Special";
          shortDescription = "Judge the right level of generality";
          defaultPrompt = "Use $general-vs-special to review whether this module is too specific or too general.";
        };
        module-boundaries = {
          path = "skills/module-boundaries";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Module Boundaries";
          shortDescription = "Decide what to merge and what to split";
          defaultPrompt = "Use $module-boundaries to review how this code is divided into modules.";
        };
      };
    };
    functional-design-skills = {
      owner = "yutna";
      repo = "functional-design-skills";
      rev = "3155046df678ea862ee0880c4cc361bdc7997675";
      sha256 = "17klfm7z562ra64y9182ppgm20cnxl8rlfz0d0xnmj68747dwg8s";
      licenseFile = "LICENSE";
      skills = {
        functional-designing-deep-modules = {
          path = "plugin/skills/functional-designing-deep-modules";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Deep Modules, Functional";
          shortDescription = "Audit module depth and interface size";
          defaultPrompt = "Use $functional-designing-deep-modules to audit the depth of this module.";
        };
      };
    };
    grimoire = {
      owner = "Jartan-LLC";
      repo = "grimoire";
      rev = "71673bd8a81c4dd277996e1e254984cc6df10b79";
      sha256 = "1548pb612fwgcapxj6k65lqg177sfjf3qyvv1b0b9d6zzygm2yma";
      licenseFile = "LICENSE";
      skills = {
        code-structure = {
          path = "plugins/praxis/skills/code-structure";
          tier = "lens";
          allowImplicitInvocation = true;
          displayName = "Code Structure";
          shortDescription = "Shape units by responsibility, not size";
          defaultPrompt = "Use $code-structure to review the structure of this code.";
        };
      };
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
        allow_implicit_invocation: ${lib.boolToString skill.allowImplicitInvocation}
    '';

  pstackSkillDirectory =
    name: skill:
    pkgs.runCommand "${name}-skill" { } ''
      mkdir -p "$out/agents"
      cp ${pstackFile "skills/${name}/SKILL.md" skill.sha256} "$out/SKILL.md"
      cp ${pstackLicense} "$out/LICENSE"
      cp ${codexDescriptor name skill} "$out/agents/openai.yaml"
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (relativePath: sha256: ''
          mkdir -p "$out/$(dirname ${relativePath})"
          cp ${pstackFile "skills/${name}/${relativePath}" sha256} "$out/${relativePath}"
        '') skill.referenceFiles
      )}
    '';

  claudeLoadableAgent =
    name: agent:
    pkgs.runCommand "${name}.md" { } ''
      sed -e '1,/^---$/ s/^name: .*$/name: ${name}/' ${pstackFile "agents/${name}.md" agent.sha256} > "$out"
      grep -q '^name: ${name}$' "$out"
    '';

  pstackAgentFiles = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList (name: agent: {
      "${name}.md" = claudeLoadableAgent name agent;
      "${name}.LICENSE" = pstackLicense;
    }) pstackAgents
  );

  skillDirectoryFromCheckout =
    checkout: licenseFile: name: skill:
    pkgs.runCommand "${name}-skill" { } ''
      mkdir -p "$out"
      cp -R ${checkout}/${skill.path}/. "$out/"
      chmod -R u+w "$out"
      mkdir -p "$out/agents"
      cp ${checkout}/${licenseFile} "$out/LICENSE"
      if [ ! -f "$out/agents/openai.yaml" ]; then
        cp ${codexDescriptor name skill} "$out/agents/openai.yaml"
      fi
    '';

  githubSkills = lib.foldl' lib.recursiveUpdate { } (
    lib.mapAttrsToList (
      _: source:
      let
        checkout = pkgs.fetchFromGitHub {
          inherit (source)
            owner
            repo
            rev
            sha256
            ;
          sparseCheckout = map (skill: skill.path) (lib.attrValues source.skills);
        };
      in
      lib.mapAttrs (name: skill: {
        inherit (skill) tier shortDescription;
        directory = skillDirectoryFromCheckout checkout source.licenseFile name skill;
      }) source.skills
    ) githubSkillSources
  );

  fetchedSkills =
    lib.mapAttrs (name: skill: {
      inherit (skill) tier shortDescription;
      directory = pstackSkillDirectory name skill;
    }) pstackSkills
    // githubSkills;

  skillsOfTier =
    tier: lib.mapAttrs (_: skill: skill.directory) (lib.filterAttrs (_: skill: skill.tier == tier) fetchedSkills);

  entrySkillDirectories = skillsOfTier "entry";
  lensSkillDirectories = skillsOfTier "lens";

  lensCatalog = pkgs.writeText "CATALOG.md" (
    let
      lenses = lib.filterAttrs (_: skill: skill.tier == "lens") fetchedSkills;
      row =
        name: skill:
        "| `${name}` | ${skill.shortDescription} | `${homeDir}/${skillLibraryDirectory}/${name}/SKILL.md` |";
    in
    ''
      # Agent skill library

      Judgment these agents read rather than invoke. They are installed outside the
      directories Claude and Codex scan, so they cost no context until something reads one.

      Read the `SKILL.md` at the path below, plus any `references/` file it points to.

      | Lens | Purpose | Path |
      | --- | --- | --- |
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList row lenses)}
    ''
  );

  skillFiles = managedSkillFiles;

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
    // mapFilesToTarget ".claude/agents" pstackAgentFiles
    // mapFilesToTarget ".codex/skills" skillFiles
    // {
         "${skillLibraryDirectory}/CATALOG.md" = lensCatalog;
       };

  managedCopiedDirectories =
    mapFilesToTarget ".claude/skills" entrySkillDirectories
    // mapFilesToTarget ".codex/skills" entrySkillDirectories
    // mapFilesToTarget skillLibraryDirectory lensSkillDirectories;

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

  copyDirectory =
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
      if [ -e ${lib.escapeShellArg targetPath} ]; then
        /usr/sbin/chown -R ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetPath} 2>/dev/null || true
      fi
      ${runAsPrimaryUser ''
        mkdir -p ${lib.escapeShellArg targetDir}
        rm -rf ${lib.escapeShellArg tmpPath}
        /bin/cp -Rf ${lib.escapeShellArg (toString source)} ${lib.escapeShellArg tmpPath}
        chmod -R u+w ${lib.escapeShellArg tmpPath}
        rm -rf ${lib.escapeShellArg targetPath}
        /bin/mv -f ${lib.escapeShellArg tmpPath} ${lib.escapeShellArg targetPath}
      ''}
    '';

  removeManagedPath =
    relativePath:
    let
      targetPath = "${homeDir}/${relativePath}";
    in
    ''
      if [ -e ${lib.escapeShellArg targetPath} ]; then
        /usr/sbin/chown -R ${lib.escapeShellArg managedOwner} ${lib.escapeShellArg targetPath} 2>/dev/null || true
        ${runAsPrimaryUser "rm -rf ${lib.escapeShellArg targetPath}"}
      fi
    '';

  scannedSkillDirectories = [
    ".claude/skills"
    ".codex/skills"
  ];

  stalePaths =
    lib.concatMap (name: map (dir: "${dir}/${name}") scannedSkillDirectories) (
      lib.attrNames lensSkillDirectories ++ retiredSkillNames
    )
    ++ map (name: "${skillLibraryDirectory}/${name}") retiredSkillNames;

  activationCommands =
    [
      (ensureDirectory ".claude")
      (ensureDirectory ".claude/skills")
      (ensureDirectory ".claude/agents")
      (ensureDirectory ".codex")
      (ensureDirectory ".codex/skills")
      (ensureDirectory skillLibraryDirectory)
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
    ++ map removeManagedPath stalePaths
    ++ lib.mapAttrsToList linkFile managedLinkedFiles
    ++ lib.mapAttrsToList copyFile managedCopiedFiles
    ++ lib.mapAttrsToList copyDirectory managedCopiedDirectories;
in
{
  system.activationScripts.postActivation.text = lib.mkBefore (
    lib.concatStringsSep "\n" activationCommands
  );
}
