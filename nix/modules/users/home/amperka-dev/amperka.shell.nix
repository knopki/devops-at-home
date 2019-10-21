let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = {
    nixpkgs-stable = {
      # NixOS 19.09 @ 2019-10-11
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "8bf142e001b6876b021c8ee90c2c7cec385fe8e9";
      sha256 = "1z8id8ix24ds9i7cm8g33v54j7xbhcpwzw50wlq00alj00xrq307";
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
              version = "1.3.1";
              src = super.fetchurl {
                url = "https://get.pulumi.com/releases/sdk/pulumi-v${version}-linux-x64.tar.gz";
                sha256 = "1sqy0sm084cxqxnwlnqp566sdpy31l8ciyni6fridd0y5hqnp3ga";
              };
            }
          );
          pulumi-resource-gcp = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = "1.3.0";
              pname = "pulumi-resource-gcp";
              src = super.fetchurl {
                url = "https://api.pulumi.com/releases/plugins/pulumi-resource-gcp-v${version}-linux-amd64.tar.gz";
                sha256 = "04l086a8ab72w5d7l59xl49lcwjq05n1fkhx1pxm5x7l5zw1id6y";
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
    python37Packages.setuptools
    python37Packages.virtualenv
    python3Full
    rsync
    stdenv
    yarn
  ];
}
