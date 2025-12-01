{
  self,
  config,
  ...
}:
{
  preservation.preserveAt."/state".users.root = {
    # specify user home when it is not `/home/${user}`
    home = "/root";
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".local/share/chezmoi"
      ".local/state/nix"
    ];
    files = [ ];
  };

  sops.secrets = {
    root-user-password.neededForUsers = true;
    root-chezmoi-age-key = { };
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-user-password.path;
    openssh.authorizedKeys.keys = [
      self.lib.sshPubKeys.knopkiSshPubKey1
    ];
  };

  systemd.user.tmpfiles.users.root.rules = self.lib.preservationPolicies.commonUserTmpfilesRules;
}
