{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
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
    openssh.authorizedKeys.keyFiles = [ ./knopki_id_rsa.pub ];
    hashedPassword = "$y$j9T$Ic5vgoASIsa5wEgNyv/Iy.$3pg6OOd.eGOvvNriX60AFsXk5LueWJBbLpR3CBwBaS4";
    # passwordFile = config.sops.secrets.rog-knopki-user-password.path;
  };

  home-manager.users.knopki =
    { ... }:
    {
      imports = with self.modules.homeManager; [ profiles-knopki-at-rog ];
    };
}
