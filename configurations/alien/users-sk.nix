{
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.users.users.sk;
in
{
  imports = [ ./users-sk-pim.nix ];

  users.groups.sk.gid = mkDefault 1000;

  users.users.sk = {
    description = "Sergei Korolev";
    uid = mkDefault 1000;
    group = "sk";
    isNormalUser = true;
    hashedPasswordFile = mkDefault config.sops.secrets.sk-user-password.path;
    extraGroups = with config.users.groups; [
      cfg.group
      "adbusers"
      "audio"
      "dialout"
      "disk"
      "input"
      "mlocate"
      "networkmanager"
      "plugdev"
      "podman"
      "pulse"
      "sound"
      "users"
      "video"
      "wheel"
      "wireshark"
      keys.name
    ];

    linger = true;
    openssh.authorizedKeys.keys = [
      self.lib.ssh-pubkeys.knopki-ssh-pubkey1
    ];
  };

  home-manager.users.sk = {
    imports = with self.modules.homeManager; [ profiles-sk-at-alien ];
    home.username = "sk";
    home.homeDirectory = "/home/sk";
  };

  sops = {
    secrets = {
      sk-user-password.neededForUsers = true;
      sk-chezmoi-age-key.owner = config.users.users.sk.name;
    };
  };
}
