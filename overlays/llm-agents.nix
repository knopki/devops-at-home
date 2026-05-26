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
    cli-proxy-api
    mcporter
    openspec
    rtk
    spec-kit
    tuicr
    ;
  codex = pkgIfVersionMin prev.codex "0.118" p.codex;
  gemini-cli = pkgIfVersionMin prev.gemini-cli "0.30" p.gemini-cli;
  nono = pkgIfVersionMin prev.nono "0.55.0" p.nono;
  opencode = pkgIfVersionMin prev.opencode "1.15.0" p.opencode;
}
