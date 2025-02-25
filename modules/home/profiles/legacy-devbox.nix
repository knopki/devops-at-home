{
  config,
  lib,
  pkgs,
  self,
  osConfig,
  ...
}:
{
  imports = with self.modules.homeManager; [
    profiles-legacy-graphical
    profiles-legacy-workstation
  ];

  home = {
    file = {
      ".npmrc".text = ''
        cache="${config.xdg.cacheHome}/npm"
        prefix="${config.xdg.dataHome}/npm"
      '';
    };
  };
}
