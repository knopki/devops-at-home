{ self, config, ... }:
{
  home-manager.users.root =
    { ... }:
    {
      imports = with self.modules.homeManager; [ profiles-root-at-rog ];
    };

  preservation.preserveAt."/state".users.root = {
    # specify user home when it is not `/home/${user}`
    home = "/root";
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };

  sops.secrets.root-user-password.neededForUsers = true;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
  };
}
