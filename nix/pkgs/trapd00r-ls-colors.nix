{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "trapd00r-ls-colors-${version}";
  version = "0.0.1";

  src = fetchFromGitHub
    (builtins.fromJSON (builtins.readFile ./versions.json)).LS_COLORS;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r LS_COLORS $out/LS_COLORS
  '';
}
