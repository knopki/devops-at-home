{
  config,
  pkgs,
  self,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
  ];

  preservation.preserveAt."/state".users.knopki = {
    directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      ".local/share/chezmoi"
      ".local/share/direnv"
      ".local/state/nix"
      ".mozilla"
      "prj"
    ];
    files = [
    ];
  };

  sops.secrets = {
    knopki-user-password.neededForUsers = true;
    knopki-chezmoi-age-key.owner = config.users.users.knopki.name;
  };

  users.groups.knopki = { };
  users.users.knopki = {
    description = "Red Buttons";
    uid = 1000;
    group = "knopki";
    isNormalUser = true;
    extraGroups = with config.users.groups; [
      "adbusers"
      "audio"
      "dialout"
      "disk"
      "input"
      "libvirtd"
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
    openssh.authorizedKeys.keys = [
      self.lib.sshPubKeys.knopkiSshPubKey1
    ];
    hashedPasswordFile = config.sops.secrets.knopki-user-password.path;
  };

  systemd.user.tmpfiles.users.knopki.rules = self.lib.preservationPolicies.commonUserTmpfilesRules;
}
