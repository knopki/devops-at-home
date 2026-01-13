{
  self,
  config,
  ...
}:
{
  custom.preservation = {
    preserveAtTemplates."/state".users.root = {
      auto.enable = true;
      xdgTmpfiles.enable = true;
    };
    preserveAt."/state".users.root = {
      directories = [ ];
      files = [ ];
    };
    preserveAtTemplates."/state/sensitive".users.root.secrets.enable = true;
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
}
