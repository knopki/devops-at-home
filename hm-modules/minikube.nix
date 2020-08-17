{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.minikube.enable = mkEnableOption "minikube configuration";

  config = mkIf config.knopki.minikube.enable {
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

    home.packages = with pkgs; [ docker-machine-kvm2 minikube ];
  };
}
