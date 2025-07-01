{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  ...
}:
stdenv.mkDerivation {
  pname = "base16-textmate";
  version = "0-unstable-2022-08-17";
  src = fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-textmate";
    rev = "0e51ddd568bdbe17189ac2a07eb1c5f55727513e";
    fetchSubmodules = false;
    sha256 = "sha256-reYGXrhhHNSp/1k6YJ2hxj4jnJQCDgy2Nzxse2PviTA=";
  };

  installPhase = ''
    mkdir -p $out
    cp -a Themes $out/
    cp -a templates $out/
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Base16 for TextMate & Sublime Text 2/3";
    homepage = "https://github.com/chriskempson/base16-textmate";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
