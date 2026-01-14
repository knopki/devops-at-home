{
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

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

}
