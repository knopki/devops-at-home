{
  # config
  config-home-manager = ./config/home-manager.nix;
  config-locale = ./config/locale.nix;
  config-nix = ./config/nix.nix;
  config-preservation = ./config/preservation.nix;
  config-zswap = ./config/zswap.nix;

  # misc
  misc-common-mixin = ./misc/common-mixin.nix;
  misc-no-docs = ./misc/no-docs.nix;

  # profiles

  # programs
  program-applists = ./programs/applists.nix;
  program-helix = ./programs/helix.nix;
  program-htop = ./programs/htop.nix;
  program-ssh-well-known-hosts = ./programs/ssh-well-known-hosts.nix;

  # roles
  role-devhost = ./roles/devhost.nix;
  role-server = ./roles/server.nix;
  role-workstation = ./roles/workstation.nix;

  # security
  security-sudo = ./security/sudo.nix;

  # services
  service-cosmic-de = ./services/cosmic-de.nix;
  service-networking = ./services/networking.nix;
  service-openssh = ./services/openssh.nix;
  service-pipewire = ./services/pipewire.nix;

  # system
  system-lanzaboote = ./system/lanzaboote.nix;
  system-systemd-boot = ./system/systemd-boot.nix;
}
