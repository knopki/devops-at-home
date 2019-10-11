let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = {
    nixpkgs-stable = {
      # NixOS 19.09 @ 2019-10-11
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "9bbad4c6254513fa62684da57886c4f988a92092";
      sha256 = "00dhkkmar3ynfkx9x0h7hzjpcqvwsfmgz3j0xj80156kbw7zq4bb";
    };
    devops-at-home = {
      # knopki/devops-at-home @ 2019-09-26
      owner = "knopki";
      repo = "devops-at-home";
      rev = "29f82083ab9ddebc76f1f64c0fcd5dbe62b50649";
      sha256 = "0pdl2g0hws5d99gamw64dbxag56z9skjjjkb7c7lcdva0w2ilmbz";
    };
  };
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          kube-score = super.callPackage "${fetchFromGitHub versions.devops-at-home}/nix/pkgs/kube-score" {};
          pulumi-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.2.0";
              src = super.fetchurl {
                url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
                sha256 = "1hcnx19p06pjbr8hbv9qcwfsip6jxkzpca6sqa5m98d325alfx50";
              };
            }
          );
          pulumi-resource-gcp = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.2.0";
              pname = "pulumi-resource-gcp";
              src = super.fetchurl {
                url = "https://api.pulumi.com/releases/plugins/pulumi-resource-gcp-v${version}-linux-amd64.tar.gz";
                sha256 = "1971q8wcfk75w684i42fq6ingn9x29q5bdyfcjgqlywjn76c4mwi";
              };
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-mysql = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.0.0";
              pname = "pulumi-resource-mysql";
              src = super.fetchurl {
                url = "https://api.pulumi.com/releases/plugins/pulumi-resource-mysql-v${version}-linux-amd64.tar.gz";
                sha256 = "0nh6rzd7rih5srkn7cb3lq79bsxbnk9zamdpyxvrqivngsxw8k9c";
              };
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-kubernetes = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.1.0";
              pname = "pulumi-resource-kubernetes";
              src = super.fetchurl {
                url = "https://api.pulumi.com/releases/plugins/pulumi-resource-kubernetes-v${version}-linux-amd64.tar.gz";
                sha256 = "0rczcfmwwscxm423lq81x4pgfcqg4jmairzjcbd3p6acqd72452j";
              };
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    cloud-sql-proxy
    curl
    direnv
    docker-compose
    google-cloud-sdk
    jq
    kube-score
    kubectl
    mysql57
    nodejs
    openssh
    php
    php73Packages.composer
    pulumi-bin
    pulumi-resource-gcp
    pulumi-resource-kubernetes
    pulumi-resource-mysql
    python37Packages.pip
    python37Packages.virtualenv
    python3Full
    rsync
    stdenv
    yarn
  ];
}
