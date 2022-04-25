{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    fishPlugins.fish-kubectl-completions
    google-cloud-sdk
    kubectl
    kubectl-cert-manager
    debootstrap
  ];
}
