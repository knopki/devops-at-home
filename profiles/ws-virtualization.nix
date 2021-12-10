{ pkgs, lib, ... }:
let inherit (lib) mkDefault; in
{
  environment = {
    sessionVariables = {
      VAGRANT_DEFAULT_PROVIDER = "libvirt";
    };

    systemPackages = with pkgs; [ virt-manager ];
  };

  virtualisation = {
    containers.enable = true;

    docker = {
      autoPrune.dates = mkDefault "weekly";
      autoPrune.enable = mkDefault true;
      enable = mkDefault true;
      enableOnBoot = mkDefault false;
      liveRestore = mkDefault true;
    };
    libvirtd = {
      enable = true;
      qemu.runAsRoot = false;
      allowedBridges = [ "virbr0" "virbr1" ];
    };

    oci-containers.backend = "podman";

    podman.enable = true;
  };
}
