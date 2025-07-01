{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-vim";
  version = "0-unstable-2022-09-20";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-vim";
    rev = "3be3cd82cd31acfcab9a41bad853d9c68d30478d";
    fetchSubmodules = false;
    sha256 = "sha256-uJvaYYDMXvoo0fhBZUhN8WBXeJ87SRgof6GEK2efFT0=";
  };
  date = "2022-09-20";

  installPhase = ''
    mkdir -p $out
    cp -a colors $out/
    cp -a templates $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Base16 Vim";
    homepage = "https://github.com/chriskempson/base16-vim";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
