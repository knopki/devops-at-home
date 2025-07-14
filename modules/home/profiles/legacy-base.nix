{
  lib,
  pkgs,
  osConfig,
  self,
  ...
}:
let
  inherit (lib) mkDefault mkIf optionals;
in
{
  home = {
    # by default, state version is machine's state version
    stateVersion = mkDefault (optionals (osConfig != null) osConfig.system.stateVersion);
  };

  nix = mkIf (osConfig == null) {
    package = mkDefault pkgs.nix;
    settings = {
      inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
    };
  };

  programs = {
    man.generateCaches = false;
  };
}
