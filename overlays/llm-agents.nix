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
    bernstein
    cli-proxy-api
    codegraph
    hermes-desktop
    mcporter
    openspec
    pi
    rtk
    tuicr
    ;
  agent-browser = pkgIfVersionMin prev.agent-browser "0.26" p.agent-browser;
  codex = pkgIfVersionMin prev.codex "0.118" p.codex;
  gemini-cli = pkgIfVersionMin prev.gemini-cli "0.30" p.gemini-cli;
  nono = pkgIfVersionMin prev.nono "0.55.0" p.nono;
  opencode = pkgIfVersionMin prev.opencode "1.16.0" p.opencode;
}
