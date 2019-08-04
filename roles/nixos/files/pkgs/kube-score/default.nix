{ lib, stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "kube-score-${version}";
  version = "0.5.0";
  rev = "10977a9381a72e22798140cbd8b2efcafcf1b6a9";

  goPackagePath = "github.com/zegl/kube-score";

  buildFlagsArray = let t = "${goPackagePath}/pkg/commands";
    in ''
      -ldflags=
        -s -X ${t}.kubeScoreVersion=${version}
           -X ${t}.gitCommit=${rev}
           -X ${t}.buildDate=unknown
    '';

  src = fetchFromGitHub {
    sha256 = "11yzz8p8d1qh3gskr8m6lgj9dzi21ksfq6fyhzzb0yg1w4jnn2id";
    rev = "v${version}";
    repo = "kube-score";
    owner = "zegl";
  };

  meta = with lib; {
    description = "Customization of kubernetes YAML configurations";
    longDescription = ''
      kustomize lets you customize raw, template-free YAML files for
      multiple purposes, leaving the original YAML untouched and usable
      as is.
    '';
    homepage = "https://github.com/zegl/kube-score";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };

  goDeps = ./deps.nix;
}
