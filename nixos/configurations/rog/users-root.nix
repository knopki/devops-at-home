{ self, config, ... }:
{
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
    openssh.authorizedKeys.keys = [
      self.lib.ssh-pubkeys.knopki-ssh-pubkey1
    ];
  };
}
