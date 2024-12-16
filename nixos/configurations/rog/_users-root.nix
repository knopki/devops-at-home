{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  users.users.root = {
    hashedPassword = "$y$j9T$oz0dXbu9fVRSXj2.pcAbw0$HlXKMmJ/OXIoqRRgVX4Wzebsh5K6o1cUd.azvemKm07";
    # passwordFile = config.sops.secrets.rog-root-user-password.path;
  };

  home-manager.users.root =
    { ... }:
    {
      imports = with self.modules.homeManager; [ profiles-root-at-rog ];
    };
}
