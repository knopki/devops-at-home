{
  config,
  nixosConfig,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  home = {
    # by default, state version is machine's state version
    stateVersion = mkDefault nixosConfig.system.stateVersion;
  };

  # sometimes rewriten by evil forces and prevent activation
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
}
