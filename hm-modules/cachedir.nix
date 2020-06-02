{ config, lib, pkgs, ... }:
with lib;
let
  tag = ''
    Signature: 8a477f597d28d172789f06886806bc55
  '';
in
{
  options.knopki.cachedirs = mkOption {
    type = with types; listOf str;
    default = [];
    description = ''
      Paths to dirs where to create CACHEDIR.TAG files.
    '';
  };

  config = {
    home.file = mkMerge
      (map (x: { "${x}/CACHEDIR.TAG".text = tag; }) config.knopki.cachedirs);
  };
}
