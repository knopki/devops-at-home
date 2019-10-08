{ config, lib, ... }:

with lib;

{
  options.local.hardware.intel = mkEnableOption "Is Intel CPU?";

  config.hardware.cpu.intel.updateMicrocode = mkDefault config.local.hardware.intel;
  config.boot.initrd.availableKernelModules = mkIf (
    !config.local.hardware.vmGuest && length (attrNames config.boot.initrd.luks.devices) > 0 && config.local.hardware.intel
  ) [
    "aes_x86_64"
    "aesni_intel"
    "cryptd"
  ];
  config.boot.kernelModules = mkIf (
    !config.local.hardware.vmGuest && config.local.hardware.intel
  ) [ "kvm-intel" ];
}
