{
  config,
  lib,
  self,
  ...
}:
{
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
  };

  sops.secrets = {
    root-user-password.neededForUsers = true;
    root-chezmoi-age-key = { };
  };

  home-manager.users.root = {
    imports = with self.modules.homeManager; [ profiles-root-at-alien ];
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
