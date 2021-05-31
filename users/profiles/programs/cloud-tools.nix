{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    dive
    fishPlugins.fish-kubectl-completions
    google-cloud-sdk
    kubectl
  ];
}
