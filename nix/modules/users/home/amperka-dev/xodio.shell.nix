let
  # inject "sources = ..." under this line
  include = 1;
  # end
  pkgs = import sources.nixpkgs {
    overlays = [
      (
        self: super: {
          unstable = import sources.nixpkgs-unstable {};
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
          kube-score = super.nur.repos.knopki.kube-score;
          kustomize = (import sources.nixpkgs-kustomize-1 {}).kustomize;
          telepresence = super.unstable.telepresence;
        }
      )
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
    kube-score
    kubectl
    kubernetes-helm
    kustomize
    nodejs
    nodePackages.node-gyp
    python2Full
    rsync
    stdenv
    telepresence
    yarn
  ];
}
