{ nixosConfig, ... }:
{
  programs.imv = {
    enable = nixosConfig.meta.suites.workstation;
    settings = {
      binds = {
        "<Shift+Left>" = "prev 10";
        "<Shift+Right>" = "next 10";
      };
    };
  };
}
