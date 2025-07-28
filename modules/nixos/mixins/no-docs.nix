{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  documentation = {
    # Notice this also disables --help for some commands such as nixos-rebuild
    enable = mkDefault false;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
    man.enable = mkDefault false;
    nixos.enable = mkDefault false;
  };
}
