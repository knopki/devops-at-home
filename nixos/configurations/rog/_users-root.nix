{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  users.users.root = {
    isNormalUser = true;
    hashedPassword = "$6$QOTimFq0v8u6oN.I$.m0BQc/tC6/8nluwwQT7AmkbJbfNoh2PnO9biVL4wgWA22zlb/0HheieexWgISAB67r/7floX3bQpZrUjZv9v.";
  };

  home-manager.users.root = {... }:  {
    imports = with self.homeManagerModules; [
      profiles-root-at-rog
    ];
  };
}
