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

    # linger = true; # TODO
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0ZfU7o78neKOrh7+ik4tyzkpl5d4yQ1YnZyrhMRVkiOw8PxyjruW8LLOnVwyes6doEg9rArr/6xm6jHQxDNKalYj3qYK16b1nAyajp1K0jGFHLRMfPxjY2r5zmg3FMgdT1AqbkEr8puTXsnOo4UZRKnpqs8wpJjZ3K7JuaQxJXjtR6f12RgZ0QUukZaa4gJPCrmx7JSvP1C9DuuyLN3rrGIwOAbF0Kc2g6X5Xr2f3GnGAWNL8xz4E6+Yl8wCOmMpV4b3a+0rv/b8UX2pKfMk1uuKvOxRJ0LzLZQ2IXTwEiiv5mHe/ExSvwScVRcpEU5Zpq1W6BOPztchTwoaEdsqXw== knopki"
    ];
  };

  home-manager.users.sk = {
    imports = with self.modules.home; [ profiles-sk-at-alien ];
    home.username = "sk";
    home.homeDirectory = "/home/sk";
  };

  sops = {
    secrets = {
      sk-user-password = {
        neededForUsers = true;
      };
    };
  };
}
