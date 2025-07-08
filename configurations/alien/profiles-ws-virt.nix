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
    oci-containers.backend = mkDefault "podman";
    podman = {
      enable = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
