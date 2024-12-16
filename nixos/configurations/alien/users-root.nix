{
  config,
  lib,
  self,
  ...
}:
{
  users.users.root = {
    passwordFile = config.sops.secrets.root-user-password.path;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0ZfU7o78neKOrh7+ik4tyzkpl5d4yQ1YnZyrhMRVkiOw8PxyjruW8LLOnVwyes6doEg9rArr/6xm6jHQxDNKalYj3qYK16b1nAyajp1K0jGFHLRMfPxjY2r5zmg3FMgdT1AqbkEr8puTXsnOo4UZRKnpqs8wpJjZ3K7JuaQxJXjtR6f12RgZ0QUukZaa4gJPCrmx7JSvP1C9DuuyLN3rrGIwOAbF0Kc2g6X5Xr2f3GnGAWNL8xz4E6+Yl8wCOmMpV4b3a+0rv/b8UX2pKfMk1uuKvOxRJ0LzLZQ2IXTwEiiv5mHe/ExSvwScVRcpEU5Zpq1W6BOPztchTwoaEdsqXw== knopki"
    ];
  };

  sops.secrets = {
    root-user-password = {
      neededForUsers = true;
    };
  };

  home-manager.users.root = {
    imports = with self.modules.home; [ profiles-root-at-alien ];
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
