{ lib }:
let
  inherit (builtins) elem;
  inherit (lib) getName getNameWithVersion;

  allowlistedLicenses = [ ];
  allowUnfreePredicate =
    pkg:
    elem (getName pkg) [
      "anytype"
      "anytype-heart"
      "cursor"
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
