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
    dsh
    hermes-desktop
    mcporter
    tuicr
    reasonix
    ;
  agent-browser = pkgIfVersionMin prev.agent-browser "0.26" p.agent-browser;
  code = pkgIfVersionMin prev.code "0.6.145" p.code;
  gemini-cli = pkgIfVersionMin prev.gemini-cli "0.30" p.gemini-cli;
  herdr = pkgIfVersionMin prev.herdr "0.8" p.herdr;
  nono = pkgIfVersionMin prev.nono "0.63.0" p.nono;
  opencode = pkgIfVersionMin prev.opencode "1.16.0" p.opencode;
  openspec = pkgIfVersionMin prev.openspec "1.4.0" p.openspec;
  pi-coding-agent = pkgIfVersionMin prev.pi-coding-agent "0.82" p.pi;
}
