{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-dracula-scheme";
  version = "0-unstable-2022-03-01";
  src = fetchFromGitHub {
    owner = "dracula";
    repo = "base16-dracula-scheme";
    rev = "9494b73c343dde092edb05db51f1fd238395f10a";
    fetchSubmodules = false;
    sha256 = "sha256-iHe/Y0+yubXseh3gMWb6wZ4rIb1GAlb6iQNVgiEncfI=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a *.yaml $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Dracula for Base16";
    homepage = "https://github.com/dracula/base16-dracula-scheme";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
