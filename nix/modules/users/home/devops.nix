{ config, lib, pkgs, user, ... }:
with lib; {
  options.local.devops.enable = mkEnableOption "devops pack";

  config = mkIf config.local.devops.enable {
    home.file = {
      ".minikube/config/config.json".text = builtins.toJSON {
        dashboard = false;
        disk-size = "20g";
        ingress = false;
        memory = 4096;
        ShowBootstrapperDeprecationNotification = false;
        vm-driver = "kvm2";
        WantKubectlDownloadMsg = false;
        WantUpdateNotification = false;
      };
    };

    home.packages = with pkgs; [
      bat
      curl
      docker-machine-kvm2
      gnupg
      google-cloud-sdk
      graphviz
      htop
      jq
      keepassxc
      kube-score
      kubectl
      kubernetes-helm
      minikube
      mosh
      nix-du
      nix-prefetch-git
      nixpkgs-with-kustomize-1.kustomize
      nmap-graphical
      openssh
      pstree
      remmina
      ripgrep
      rsync
      shfmt
      sysstat
      telepresence
      wget
    ];

    local.editorconfig = true;
    local.vscode.enable = true;
  };
}
