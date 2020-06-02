{ pkgs, lib, runCommand, packagePlugin, ... }:
with lib;
let
  mySrc = pkgs.fetchFromGitHub {
    owner = "evanlucas";
    repo = "fish-kubectl-completions";
    rev = "09c1e7e4803bb5b3a16dd209d3663207579bf6de";
    sha256 = "15k0khzfkms2bh4b4x3fa142wmmn6cfd044mclj3d12fvylr366f";
  };

  name = "kubectl";
  version = "dbcd150a1c7b4b96da8c63b654de43bf8271c2f1";

  src = runCommand "fish-completion-${name}-${version}-src" {
    src = "${mySrc}/completions/kubectl.fish";
  } ''
    mkdir -p $out/completions
    cp $src $_/${name}.fish
  '';
in
packagePlugin {
  inherit src;
  name = "${name}-completion-${version}";
  meta = {
    license = licenses.mit;
    description = "kubectl completions for fish shell";
  };
}
