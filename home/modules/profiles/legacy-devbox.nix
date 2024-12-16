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
    packages = with pkgs; [
      google-cloud-sdk
      kubectl
      # kubectl-cert-manager
    ];

    file = {
      ".npmrc".text = ''
        cache="${config.xdg.cacheHome}/npm"
        prefix="${config.xdg.dataHome}/npm"
      '';
    };
  };
}
