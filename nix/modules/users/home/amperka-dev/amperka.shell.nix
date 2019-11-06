let
  # inject "sources = ..." under this line
  include = 1;
  # end
  nur-no-pkgs = import sources.nur {
    repoOverrides = { knopki = import sources.nur-knopki {}; };
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
      nur-no-pkgs.repos.knopki.overlays.nodePackages
      nur-no-pkgs.repos.knopki.overlays.pulumi
      nur-no-pkgs.repos.knopki.overlays.telepresence
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
    nodePackages.yarn-deduplicate
    openssh
    php
    php73Packages.composer
    pulumi-bin
    pulumi-resource-gcp-bin
    pulumi-resource-kubernetes-bin
    pulumi-resource-mysql-bin
    python37Packages.autopep8
    python37Packages.black
    python37Packages.pip
    python37Packages.pycodestyle
    python37Packages.pylint
    python37Packages.setuptools
    python37Packages.virtualenv
    python3Full
    rsync
    stdenv
    telepresence
    yarn
  ];
}
