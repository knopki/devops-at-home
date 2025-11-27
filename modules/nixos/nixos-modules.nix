{
  home-manager = ./home-manager.nix;

  # mixins
  mixin-cosmic-de = ./mixins/cosmic-de.nix;
  mixin-essential-server-packages = ./mixins/essential-server-packages.nix;
  mixin-locale-black-russian = ./mixins/locale-black-russian.nix;
  mixin-locale-white-russian = ./mixins/locale-white-russian.nix;
  mixin-networking = ./mixins/networking.nix;
  mixin-nix = ./mixins/nix.nix;
  mixin-no-docs = ./mixins/no-docs.nix;
  mixin-openssh = ./mixins/openssh.nix;
  mixin-pipewire = ./mixins/pipewire.nix;
  mixin-preservation-common = ./mixins/preservation-common.nix;
  mixin-sudo = ./mixins/sudo.nix;
  mixin-systemd-boot = ./mixins/systemd-boot.nix;
  mixin-terminfo = ./mixins/terminfo.nix;
  mixin-trusted-nix-caches = ./mixins/trusted-nix-caches.nix;
  mixin-well-known-hosts = ./mixins/well-known-hosts.nix;

  # profiles
  profile-common = ./profiles/common.nix;
  profile-devhost = ./profiles/devhost.nix;
  profile-server = ./profiles/server.nix;
  profile-workstation = ./profiles/workstation.nix;

  # programs
  programs-helix = ./programs/helix.nix;
}
