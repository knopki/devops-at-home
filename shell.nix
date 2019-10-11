let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = builtins.fromJSON
    (builtins.readFile ./nix/pkgs/versions.json);
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          unstable = import (fetchFromGitHub versions.nixpkgs-unstable) {
            config.allowUnfree = true;
          };
        }
      )
      (
        self: super: {
          morph = super.callPackage "${fetchFromGitHub versions.morph}/nix-packaging" {};
          pulumi-bin = super.pulumi-bin.overrideAttrs (old: rec {
            version = "1.3.1";
            src = super.fetchurl {
              url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
              sha256 = "1sqy0sm084cxqxnwlnqp566sdpy31l8ciyni6fridd0y5hqnp3ga";
            };
          });
          pulumi-resource-gcp = super.pulumi-bin.overrideAttrs (old: rec {
            version = "1.3.0";
            pname = "pulumi-resource-gcp";
            src = super.fetchurl {
              url = "https://api.pulumi.com/releases/plugins/pulumi-resource-gcp-v${version}-linux-amd64.tar.gz";
              sha256 = "04l086a8ab72w5d7l59xl49lcwjq05n1fkhx1pxm5x7l5zw1id6y";
            };
            setSourceRoot = "sourceRoot=`pwd`";
          });
        }
      )
    ];
  };

in
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    morph
    nix-prefetch-git
    nixpkgs-fmt
    nodejs
    openssh
    pulumi-bin
    pulumi-resource-gcp
    shellcheck
    shfmt
    stdenv
    yarn
  ];
}
