{ lib, pkgs, ... }:
with lib;
let
  src = pkgs.fetchFromGitHub {
    owner = "zegl";
    repo = "kube-score";
    rev = "bdb07f1e3d5ff8a2c2c1b4086d68d5ec7f739432";
    sha256 = "19gpmksnfj801wj69x4z5s33kn2c4y7ddis3kdwd2bmma00vnrkm";
  };
in
pkgs.buildGoPackage rec {
  inherit src;
  name = "kube-score-${version}";
  version = "0.7.1";
  goPackagePath = "github.com/zegl/kube-score";
  goDeps = ./deps.nix;

  buildFlagsArray = ''
    -ldflags=
      -s -w -X main.version=${version}
            -X main.commit=${src.rev}
  '';

  meta = {
    license = licenses.mit;
    platforms = platforms.all;
    description = "Kubernetes object analysis with recommendations for improved reliability and security";
    homepage = "https://kube-score.com";
  };
}
