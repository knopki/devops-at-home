{ config, ... }:
{
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
  };

  sops.secrets = {
    root-user-password.neededForUsers = true;
    root-chezmoi-age-key = { };
  };

  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "20.09";

    programs = {
      man.generateCaches = false;
    };
  };
}
