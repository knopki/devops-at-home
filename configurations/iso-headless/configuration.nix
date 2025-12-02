{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = with self.modules.nixos; [ profile-nix ];

  profiles.nix.enable = true;

  environment.systemPackages = with pkgs; [
    binutils
    curl
    dosfstools
    dust
    fd
    file
    gnupg
    gptfdisk
    helix
    iputils
    lsof
    pstree
    python3
    ripgrep
    rsync
    tree
    wget
  ];

  nix.gc.automatic = false;

  programs = {
    git.enable = true;
    fish.enable = true;
    nh.clean.enable = false;
  };

  users.users.nixos = {
    shell = config.programs.fish.package;
    openssh.authorizedKeys.keys = [
      self.lib.sshPubKeys.knopkiSshPubKey1
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    self.lib.sshPubKeys.knopkiSshPubKey1
  ];
}
