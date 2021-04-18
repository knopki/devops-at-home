{ config, nixosConfig, lib, pkgs, ... }:
let inherit (lib) mkDefault; in
{
  home = {
    stateVersion = mkDefault nixosConfig.system.stateVersion;
  };

  programs = {
    bash.enable = true;
    bat.enable = true;
    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };
    jq.enable = true;
    lesspipe.enable = true;
    man.generateCaches = lib.mkIf nixosConfig.meta.suites.workstation true;
  };
}
