let
  # inject "sources = ..." under this line
  include = 1;
  # end
  nur-no-pkgs = import sources.nur {
    repoOverrides = { knopki = import sources.nur-knopki; };
  };
  pkgs = import sources.nixpkgs {
    overlays = [
      (
        self: super: {
          nur = import sources.nur {
            inherit pkgs;
            repoOverrides = {
              knopki = import sources.nur-knopki { inherit pkgs; };
            };
          };
        }
      )
      (
        self: super: {
          pulumi-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = sources.pulumi-bin.version;
              src = sources.pulumi-bin;
            }
          );
          pulumi-resource-gcp-bin = super.pulumi-bin.overrideAttrs (
            old: {
              version = sources.pulumi-resource-gcp-bin.version;
              pname = "pulumi-resource-gcp-bin";
              src = sources.pulumi-resource-gcp-bin;
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-mysql-bin = super.pulumi-bin.overrideAttrs (
            old: {
              version = sources.pulumi-resource-mysql-bin.version;
              pname = "pulumi-resource-mysql-bin";
              src = sources.pulumi-resource-mysql-bin;
              setSourceRoot = "sourceRoot=`pwd`";
            }
          );
          pulumi-resource-kubernetes-bin = super.pulumi-bin.overrideAttrs (
            old: rec {
              version = sources.pulumi-resource-kubernetes-bin.version;
              pname = "pulumi-resource-kubernetes-bin";
              src = sources.pulumi-resource-kubernetes-bin;
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
