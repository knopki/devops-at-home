{ config, lib, pkgs, user, ... }:
with lib;
{
  options.local.devops.enable = mkEnableOption "devops pack";

  config = mkIf config.local.devops.enable {
    home.packages = with pkgs; [
      ansible
      bat
      curl
      docker-machine-kvm2
      gnupg
      google-cloud-sdk
      htop
      iftop
      iotop
      jq
      keepassxc
      kube-score
      kubectl
      kubernetes-helm
      minikube
      mosh
      nix-du
      nix-prefetch-git
      nmap-graphical
      openssh
      pstree
      remmina
      ripgrep
      rsync
      shfmt
      sysstat
      telepresence
      unstable.kustomize
      wget
    ];

    local.editorconfig = true;
    local.vscode.enable = true;
  };
}
