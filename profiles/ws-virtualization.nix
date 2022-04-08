{ pkgs, lib, ... }:
let inherit (lib) mkDefault; in
{
  environment = {
    etc = {
      "distrobox/distrobox.conf".text = ''
        container_manager="podman"
      '';
    };

    sessionVariables = {
      VAGRANT_DEFAULT_PROVIDER = "libvirt";
    };

    systemPackages = with pkgs; [
      dive
      distrobox
      virt-manager
      podman
      podman-compose
    ];
  };

  virtualisation = {
    containers.enable = true;

    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
      allowedBridges = [ "virbr0" "virbr1" ];
    };

    oci-containers.backend = mkDefault "podman";

    podman = {
      enable = true;
      dockerCompat = mkDefault true;
      dockerSocket.enable = true;
    };


  };
}
