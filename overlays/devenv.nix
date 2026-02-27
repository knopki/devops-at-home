_final: prev:
let
  inherit (builtins) compareVersions;
  inherit (prev.lib.strings) getVersion;
  pkgIfVersionMin =
    pkg: minVer: altPkg:
    if (compareVersions (getVersion pkg) minVer) >= 0 then pkg else altPkg;
  p = prev.devenvUpstream;
in
{
  devenv =
    let
      upstreamDevenv = p.devenv.overrideAttrs (
        _finalAttrs: _previousAttrs: {
          doCheck = false;
        }
      );
    in
    pkgIfVersionMin prev.devenv "2.0" upstreamDevenv;
}
