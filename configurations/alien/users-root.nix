{ config, ... }:
{
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
  };

  sops.secrets = {
    root-user-password.neededForUsers = true;
    root-chezmoi-age-key = { };
  };
}
