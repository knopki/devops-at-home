{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  users.users.knopki = {
    description = "Red Buttons";
    uid = 1000;
    group = "knopki";
    isNormalUser = true;
    hashedPassword = "$6$QOTimFq0v8u6oN.I$.m0BQc/tC6/8nluwwQT7AmkbJbfNoh2PnO9biVL4wgWA22zlb/0HheieexWgISAB67r/7floX3bQpZrUjZv9v.";
    extraGroups = with config.users.groups; [
      # TODO
    ];
  };

  home-manager.users.knopki = {... }:  {
    imports = with self.homeManagerModules; [
      profiles-knopki-at-rog
    ];
  };
}
