{
  config,
  pkgs,
  self,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    binutils
    curl
    dosfstools
    du-dust
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

  nix.settings = {
    inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
  };

  programs = {
    git.enable = true;
    fish.enable = true;
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
