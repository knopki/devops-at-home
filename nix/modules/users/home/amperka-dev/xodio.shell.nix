let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;
  versions = {
    nixpkgs-stable = {
      # NixOS 19.09 @ 2019-09-26
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "e34ac949d1b9847bfe09d90fdcaf2f92859a11dd";
      sha256 = "1yf9kw57d64g4153gd58bxnakhlyi9blk06gw169h37z186nsyxh";
    };
    devops-at-home = {
      # knopki/devops-at-home @ 2019-09-26
      owner = "knopki";
      repo = "devops-at-home";
      rev = "29f82083ab9ddebc76f1f64c0fcd5dbe62b50649";
      sha256 = "0pdl2g0hws5d99gamw64dbxag56z9skjjjkb7c7lcdva0w2ilmbz";
    };
    nixpkgs-kustomize-1 = {
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "2d5908f89bab59c2c4f88fbfc900dfff9baa55f0";
      sha256 = "04igl9i8x7bglwyc0fkn8fy7vcnx0f5wf2h66s818y5ywg37l020";
    };
  };
  pkgs = import "${fetchFromGitHub versions.nixpkgs-stable}" {
    overlays = [
      (
        self: super: {
          kube-score = super.callPackage "${fetchFromGitHub versions.devops-at-home}/nix/pkgs/kube-score" {};
          kustomize = (import (fetchFromGitHub versions.nixpkgs-kustomize-1) {}).kustomize;
          telepresence = super.telepresence.overrideAttrs (
            old: rec {
              version = "0.101";
              src = fetchFromGitHub {
                owner = "datawire";
                repo = "telepresence";
                rev = version;
                sha256 = "1rxq22vcrw29682g7pdcwcjyifcg61z8y4my1di7yw731aldk274";
              };
              sshuttle-telepresence = super.sshuttle.overrideDerivation (
                p: {
                  src = super.fetchgit {
                    url = "https://github.com/datawire/sshuttle.git";
                    rev = "32226ff14d98d58ccad2a699e10cdfa5d86d6269";
                    sha256 = "1q20lnljndwcpgqv2qrf1k0lbvxppxf98a4g5r9zd566znhcdhx3";
                  };

                  nativeBuildInputs = p.nativeBuildInputs ++ [ super.git ];

                  postPatch = "rm sshuttle/tests/client/test_methods_nat.py";
                  postInstall = "mv $out/bin/sshuttle $out/bin/sshuttle-telepresence";
                }
              );

              postInstall = ''
                wrapProgram $out/bin/telepresence \
                  --prefix PATH : ${pkgs.lib.makeBinPath [
                super.sshfs-fuse
                super.torsocks
                super.conntrack-tools
                sshuttle-telepresence
                super.openssh
                super.coreutils
                super.iptables
                super.bash
              ]}
              '';
            }
          );
        }
      )
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    bashInteractive
    curl
    direnv
    google-cloud-sdk
    jq
    kube-score
    kubectl
    kubernetes-helm
    kustomize
    nodejs
    openssh
    telepresence
    rsync
    yarn
  ];
}
