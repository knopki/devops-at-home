{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-shell";
  version = "0-unstable-2022-09-13";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
    fetchSubmodules = false;
    sha256 = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a * $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Base16 Shell";
    homepage = "https://github.com/chriskempson/base16-shell";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
