{
  # mixins
  mixin-preservation-common = ./mixins/preservation-common.nix;

  # profiles
  profile-applists = ./profiles/applists.nix;
  profile-common = ./profiles/common.nix;
  profile-cosmic-de = ./profiles/cosmic-de.nix;
  profile-home-manager = ./profiles/home-manager.nix;
  profile-htop = ./profiles/htop.nix;
  profile-locale = ./profiles/locale.nix;
  profile-networking = ./profiles/networking.nix;
  profile-nix = ./profiles/nix.nix;
  profile-no-docs = ./profiles/no-docs.nix;
  profile-openssh = ./profiles/openssh.nix;
  profile-pipewire = ./profiles/pipewire.nix;
  profile-ssh-well-known-hosts = ./profiles/ssh-well-known-hosts.nix;
  profile-sudo = ./profiles/sudo.nix;
  profile-systemd-boot = ./profiles/systemd-boot.nix;
  profile-terminfo = ./profiles/terminfo.nix;

  # programs
  program-helix = ./programs/helix.nix;

  # roles
  role-devhost = ./roles/devhost.nix;
  role-server = ./roles/server.nix;
  role-workstation = ./roles/workstation.nix;

  zswap = ./zswap.nix;
}
