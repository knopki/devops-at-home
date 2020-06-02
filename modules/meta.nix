{ config, lib, pkgs, ... }:
with lib;
{
  options.meta.tags = {
    isWorkstation = mkEnableOption "Is it workstation?";
    isKVMGuest = mkEnableOption "Is it KVM guest?";
  };
  options.meta.machine = mkOption {
    type = types.str;
    description = "Machine type";
  };
}
