_final: prev:
let
  inherit (builtins) compareVersions;
  inherit (prev.lib.strings) getVersion;
  pkgIfVersionMin =
    pkg: minVer: altPkg:
    if (compareVersions (getVersion pkg) minVer) >= 0 then pkg else altPkg;
  unstable = prev.nixpkgsUnstable;
  upstream = prev.devenvUpstream;
in
{
  devenv =
    let
      upstreamDevenv = upstream.devenv.overrideAttrs (
        _finalAttrs: _previousAttrs: {
          doCheck = false;
        }
      );
      unstableDevenv = unstable.devenv;
    in
    pkgIfVersionMin prev.devenv "2.0.3" (pkgIfVersionMin unstableDevenv "2.0.3" upstreamDevenv);
}
