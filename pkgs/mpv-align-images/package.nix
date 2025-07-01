{
  pkgs,
  fetchFromGitHub,
  unstableGitUpdater,
}:
pkgs.mpvScripts.buildLua {
  pname = "mpv-align-images";
  version = "0-unstable-2024-11-03";
  src = fetchFromGitHub {
    owner = "guidocella";
    repo = "mpv-image-config";
    rev = "f8ba0d22bb738bb0c55545121d525613a92b498d";
    fetchSubmodules = false;
    sha256 = "sha256-xGdbyM0igHhmvmM8g1B0pretts/ajrESf0FQysZY3ig=";
  };

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp -r scripts/align-images.lua $out/share/mpv/scripts/
  '';

  passthru.scriptName = "align-images.lua";
  passthru.updateScript = unstableGitUpdater { };
}
