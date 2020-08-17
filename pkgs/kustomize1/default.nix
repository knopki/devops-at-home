{ lib, pkgs, ... }:
with lib;
let
  src = pkgs.fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kustomize";
    rev = "383b3e798b7042f8b7431f93e440fb85631890a3";
    sha256 = "1z78d5j2w78x4ks4v745050g2ffmirj03v7129dib2lfhfjra8aj";
  };
in
pkgs.buildGoPackage rec {
  inherit src;
  name = "kustomize-${version}";
  version = "1.0.10";
  goPackagePath = "sigs.k8s.io/kustomize";

  buildFlagsArray = let
    t = "${goPackagePath}/pkg/commands";
  in
    ''
      -ldflags=
        -s -X sigs.k8s.io/kustomize/pkg/commands/misc.kustomizeVersion=${version}
           -X sigs.k8s.io/kustomize/pkg/commands/misc.gitCommit=${src.rev}
    '';

  meta = {
    license = licenses.asl20;
    platforms = platforms.all;
    description = "Customization of kubernetes YAML configurations";
    homepage = "https://sigs.k8s.io/kustomize";
  };
}
