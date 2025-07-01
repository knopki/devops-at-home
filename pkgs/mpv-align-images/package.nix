{
  pkgs,
  fetchFromGitHub,
  unstableGitUpdater,
}:
pkgs.mpvScripts.buildLua {
  pname = "mpv-align-images";
  version = "0-unstable-2025-04-07";
  src = fetchFromGitHub {
    owner = "guidocella";
    repo = "mpv-image-config";
    rev = "5c11efbf1cba194fd025f64091411bb9557d3117";
    fetchSubmodules = false;
    sha256 = "sha256-UjbYk9KclNoZNn3Q/7fer4YPq+mmuNJ2RMRhrNl5wOU=";
  };

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp -r scripts/align-images.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "align-images.lua";
  passthru.updateScript = unstableGitUpdater { };
}
