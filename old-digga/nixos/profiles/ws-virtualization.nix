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
      libguestfs-with-appliance
      virt-manager

      # docker client (docker compose, for example) can be used with podman
      docker
      podman
      podman-compose
      distrobox
    ];
  };

  virtualisation = {
    containers = {
      enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
      allowedBridges = [ "virbr0" "virbr1" ];
    };

    oci-containers.backend = mkDefault "podman";

    podman = {
      defaultNetwork.dnsname.enable = true;
      dockerSocket.enable = true;
      enable = true;
      extraPackages = with pkgs; [ aardvark-dns netavark ];
    };


  };
}
