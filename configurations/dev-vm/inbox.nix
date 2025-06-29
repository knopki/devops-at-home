{ self, ... }:
{
  users.users.root = {
    hashedPassword = "$y$j9T$Nb1KVJ2Eu7ZaGkxDWRHrD/$nDtonEpKjk.bkYXDWDzbbs9o7ElEmTcrXIncFHaarc/";
    openssh.authorizedKeys.keys = [
      self.lib.ssh-pubkeys.knopki-ssh-pubkey1
    ];
  };
}
