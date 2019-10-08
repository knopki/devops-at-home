{ config, lib, ... }:
with lib;
{
  options.local.hardware.vmGuest = mkEnableOption "Is VM guest?";

  config.local.hardware.vmGuest = mkDefault false;
}
