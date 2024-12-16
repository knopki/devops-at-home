{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = with self.modules.home; [
    profiles-legacy-base
  ];

  home.stateVersion = "20.09";
}
