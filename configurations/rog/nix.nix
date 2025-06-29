{ lib, self, ... }:
let
  inherit (lib) mkDefault;
in
{
  nix = {
    registry.self.to = {
      type = "path";
      path = self.outPath;
    };

    settings = {
      inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
      allowed-users = mkDefault [ "@wheel" ];
      auto-optimise-store = true;
    };
  };
}
