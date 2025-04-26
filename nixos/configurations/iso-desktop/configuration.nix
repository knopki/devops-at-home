{ pkgs, self, ... }:
{
  environment.systemPackages = with pkgs; [
    binutils
    curl
    dosfstools
    du-dust
    fd
    file
    gitMinimal
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
    remmina
  ];

  nix.settings = {
    inherit (self.nixConfig) experimental-features extra-substituters extra-trusted-public-keys;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
  };

  users.users.nixos.openssh.authorizedKeys.keys = [
    self.lib.ssh-pubkeys.knopki-ssh-pubkey1
  ];
  users.users.root.openssh.authorizedKeys.keys = [
    self.lib.ssh-pubkeys.knopki-ssh-pubkey1
  ];
}
