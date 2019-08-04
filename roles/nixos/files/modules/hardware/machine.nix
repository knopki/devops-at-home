{ lib, ... }:

with lib;

{
  options.local.hardware.machine = mkOption {
    description = "The machine name (usually model).";
    type = types.enum [ "alienware-15r2" "kvm" "thinkpad-T430s" ];
  };
}
