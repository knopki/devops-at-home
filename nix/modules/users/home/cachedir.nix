{ config, lib, pkgs, user, ... }:
with lib;
let
  tag = ''
    Signature: 8a477f597d28d172789f06886806bc55
  '';
in
{
  options.local.cachedirs = mkOption {
    type = with types; listOf str;
    default = [];
    description = ''
      Paths to dirs where to create CACHEDIR.TAG files.
    '';
  };

  config = {
    home.file = lib.mkMerge
      (map (x: { "${x}/CACHEDIR.TAG".text = tag; }) config.local.cachedirs);
  };
}
