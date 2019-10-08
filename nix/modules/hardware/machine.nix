{ config, lib, ... }:

with lib;

{
  options.local.hardware.machine = mkOption {
    description = "The machine name (usually model).";
    type = types.enum [ "generic" "kvm" "alienware-15r2" "thinkpad-T430s" ];
  };

  config.local.hardware.machine = mkDefault "generic";
  config.local.hardware.intel = mkDefault (any (x: x == config.local.hardware.machine) [
    "alienware-15r2"
    "thinkpad-T430s"
  ]);
}
