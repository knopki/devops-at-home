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
            version = "1.2.0";
            src = super.fetchurl {
              url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
              sha256 = "1hcnx19p06pjbr8hbv9qcwfsip6jxkzpca6sqa5m98d325alfx50";
            };
          });
          pulumi-resource-gcp = super.pulumi-bin.overrideAttrs (old: rec {
            version = "1.2.0";
            pname = "pulumi-resource-gcp";
            src = super.fetchurl {
             url = "https://api.pulumi.com/releases/plugins/pulumi-resource-gcp-v${version}-linux-amd64.tar.gz";
              sha256 = "1971q8wcfk75w684i42fq6ingn9x29q5bdyfcjgqlywjn76c4mwi";
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
