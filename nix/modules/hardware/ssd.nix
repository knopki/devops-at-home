{ config, lib, ... }:
with lib;
{
  options.local.hardware.ssd = mkEnableOption "Is SSD storage?";

  config.local.hardware.ssd = mkDefault false;
}
