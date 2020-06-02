{ lib, pkgs, stdenv, ... }:
with lib;
stdenv.mkDerivation rec {
  name = "trapd00r-ls-colors-${version}";
  version = src.rev;
  src = pkgs.fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "745b57d838dd2ffa9c6001d0f73df4303a3d957f";
    sha256 = "1q4byr56d3ngjq8il1vhgjma550yxkv1vv1cg2byclxnpig0hg79";
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r LS_COLORS $out/LS_COLORS
  '';
  meta = {
    license = licenses.artistic1;
    platform = platforms.all;
    description = "A collection of LS_COLORS definitions; needs your contribution!";
    homepage = "https://github.com/trapd00r/LS_COLORS";
  };
}
