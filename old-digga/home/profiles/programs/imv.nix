{
  nixosConfig,
  lib,
  ...
}: {
  programs.imv = {
    enable = lib.mkDefault true;
    settings = {
      binds = {
        "<Shift+Left>" = "prev 10";
        "<Shift+Right>" = "next 10";
      };
    };
  };
}
