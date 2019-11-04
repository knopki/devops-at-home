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
      nur-no-pkgs.repos.knopki.overlays.telepresence
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    curl
    dep
    direnv
    docker-compose
    go
    google-cloud-sdk
    jq
    kubectl
    kubernetes-helm
    nodejs
    nodePackages.node-gyp
    nodePackages.yarn-deduplicate
    nur.repos.knopki.kube-score
    nur.repos.knopki.kustomize1
    python2Full
    rsync
    stdenv
    telepresence
    yarn
  ];
}
