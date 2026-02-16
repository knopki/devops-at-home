_final: prev:
let
  inherit (builtins) compareVersions;
  inherit (prev.lib.strings) getVersion;
  pkgIfVersionMin =
    pkg: minVer: altPkg:
    if (compareVersions (getVersion pkg) minVer) >= 0 then pkg else altPkg;
  p = prev.llmAgents;
in
{
  inherit (p)
    agent-browser
    backlog-md
    ccusage-opencode
    handy
    localgpt
    openclaw
    openspec
    spec-kit
    tuicr
    ;
  codex = pkgIfVersionMin prev.codex "0.95" p.codex;
  gemini-cli = pkgIfVersionMin prev.gemini-cli "0.28" p.gemini-cli;
  opencode = pkgIfVersionMin prev.opencode "1.2.4" p.opencode;
}
