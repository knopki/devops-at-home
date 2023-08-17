{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    google-cloud-sdk
    kubectl
    kubectl-cert-manager
    debootstrap
  ];
}
