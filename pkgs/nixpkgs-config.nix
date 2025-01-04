{ lib }:
let
  inherit (builtins) elem;
  inherit (lib) getName getNameWithVersion;

  allowlistedLicenses = with lib.licenses; [ ];
  allowUnfreePredicate =
    pkg:
    elem (getName pkg) [
      "anytype"
      "deezer-desktop"
      "edl"
      "pantum-driver"
    ];
  allowInsecurePredicate = pkg: elem (getNameWithVersion pkg) [ ];
in
{
  inherit
    allowlistedLicenses
    allowUnfreePredicate
    allowInsecurePredicate
    ;
}
