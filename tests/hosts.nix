{
  pkgs,
  self,
  inputs,
  public,
}:
let
  inherit (pkgs) lib;

  privateDir = "${inputs.private}/modules/home-manager";
  personalEmail = (import ../modules/home-manager/common).user.email;
  workEmail = (import "${privateDir}/common").user.email;
  privateSkills = builtins.attrNames (builtins.readDir "${privateDir}/claude/skills");
  privateAgents = map (lib.removeSuffix ".md") (
    builtins.attrNames (builtins.readDir "${privateDir}/claude/agents")
  );

  user = c: lib.head (lib.attrValues c.config.home-manager.users);
  hosts = {
    strange-quark = {
      home = user self.darwinConfigurations.strange-quark;
      system = self.darwinConfigurations.strange-quark.config;
    };
    charm-quark = {
      home = user self.darwinConfigurations.charm-quark;
      system = self.darwinConfigurations.charm-quark.config;
    };
    gluon = {
      home = user self.nixosConfigurations.gluon;
      system = self.nixosConfigurations.gluon.config;
    };
    kaon = {
      home = self.homeConfigurations.kaon.config;
      system = null;
    };
  };

  facts = h: {
    gitEmail = h.home.programs.git.settings.user.email;
    jjEmail = h.home.programs.jujutsu.settings.user.email;
    privateSkills = lib.intersectLists privateSkills (
      builtins.attrNames h.home.programs.claude-code.skills
    );
    privateAgents = lib.intersectLists privateAgents (
      builtins.attrNames h.home.programs.claude-code.agents
    );
    workspaceTrust = h.home.home.activation ? claudeTrustWorkspace;
    coderTools = lib.any (p: (p.pname or "") == "coder") h.home.home.packages;
    hostName = if h.system == null then null else h.system.networking.hostName;
    computerName = h.system.networking.computerName or null;
    casks = lib.sort lib.lessThan (map (c: c.name) h.system.homebrew.casks);
  };

  work = {
    gitEmail = workEmail;
    jjEmail = workEmail;
    privateSkills = privateSkills;
    privateAgents = privateAgents;
    workspaceTrust = true;
  };
  personal = {
    gitEmail = personalEmail;
    jjEmail = personalEmail;
    privateSkills = [ ];
    privateAgents = [ ];
    workspaceTrust = false;
    coderTools = false;
    computerName = null;
  };

  expected = public {
    strange-quark = work // {
      coderTools = true;
      hostName = null;
      computerName = null;
      casks = [ "ghostty" ];
    };
    kaon = work // {
      coderTools = false;
      hostName = null;
    };
    charm-quark = personal // {
      hostName = "charm-quark";
      casks = [
        "ghostty"
        "openscad@snapshot"
      ];
    };
    gluon = personal // {
      hostName = "gluon";
    };
  };

  failures = lib.concatLists (
    lib.mapAttrsToList (
      host: want:
      let
        got = facts hosts.${host};
      in
      lib.concatLists (
        lib.mapAttrsToList (
          fact: value:
          lib.optional (
            got.${fact} != value
          ) "${host}.${fact}: expected ${builtins.toJSON value}, got ${builtins.toJSON got.${fact}}"
        ) want
      )
    ) expected
  );
in
pkgs.runCommand "test-hosts" { } (
  if failures == [ ] then
    ''
      echo "${toString (lib.length (lib.attrNames expected))} hosts checked"
      touch "$out"
    ''
  else
    ''
      printf '%s\n' ${lib.escapeShellArgs failures}
      exit 1
    ''
)
