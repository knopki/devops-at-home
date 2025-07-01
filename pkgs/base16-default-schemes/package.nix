{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-default-schemes";
  version = "0-unstable-2019-06-08";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-default-schemes";
    rev = "daf674291964321cd8c92644f9bbdbf3e7c0e8b3";
    fetchSubmodules = false;
    sha256 = "sha256-pwJCHPaHhvkkjIxQhMUm9FA5jZJSrMhu+ciA3A/dsME=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a *.yaml $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Base16 Default Schemes";
    homepage = "https://github.com/chriskempson/base16-default-schemes";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
