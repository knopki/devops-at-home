{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  environment = {
    etc = {
      "distrobox/distrobox.conf".text = ''
        container_manager="podman"
      '';
    };

    systemPackages = with pkgs; [
      dive

      # docker client (docker compose, for example) can be used with podman
      distrobox
      docker
      lima
      # podman-desktop # NOTE: disabled temporary (?) because of insecure deps
    ];
  };

  virtualisation = {
    containers = {
      enable = true;
      registries = {
        search = [
          "dockerhub.timeweb.cloud"
          "dockerhub1.beget.com"
          "mirror.gcr.io"
          "ghcr.io"
          "quay.io"
          "public.ecr.aws"
        ];
      };
    };
    oci-containers.backend = mkDefault "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };

  networking.firewall.interfaces.podman0.allowedUDPPorts = [ 53 ];
}
