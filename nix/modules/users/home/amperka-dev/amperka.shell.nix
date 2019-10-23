let
  # inject "sources = ..." under this line
  include = 1;
  # end
  pkgs = import sources.nixpkgs {
    overlays = [
      (
        self: super: {
          kube-score = super.callPackage "${sources.devops-at-home}/nix/pkgs/kube-score" {};
          pulumi-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = sources.pulumi-bin.version;
              src = super.fetchurl {
                url = sources.pulumi-bin.url;
                sha256 = sources.pulumi-bin.sha256;
              };
            }
          );
          pulumi-resource-gcp-bin = super.pulumi-bin.overrideAttrs (
            old: {
              version = sources.pulumi-resource-gcp-bin.version;
              pname = "pulumi-resource-gcp-bin";
              src = super.fetchurl {
                url = sources.pulumi-resource-gcp-bin.url;
                sha256 = sources.pulumi-resource-gcp-bin.sha256;
              };
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-mysql-bin = super.pulumi-bin.overrideAttrs (
            old: {
              version = sources.pulumi-resource-mysql-bin.version;
              pname = "pulumi-resource-mysql-bin";
              src = super.fetchurl {
                url = sources.pulumi-resource-mysql-bin.url;
                sha256 = sources.pulumi-resource-mysql-bin.sha256;
              };
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-kubernetes-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = sources.pulumi-resource-kubernetes-bin.version;
              pname = "pulumi-resource-kubernetes-bin";
              src = super.fetchurl {
                url = sources.pulumi-resource-kubernetes-bin.url;
                sha256 = sources.pulumi-resource-kubernetes-bin.sha256;
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
    pulumi-resource-gcp-bin
    pulumi-resource-kubernetes-bin
    pulumi-resource-mysql-bin
    python37Packages.pip
    python37Packages.setuptools
    python37Packages.virtualenv
    python3Full
    rsync
    stdenv
    yarn
  ];
}
