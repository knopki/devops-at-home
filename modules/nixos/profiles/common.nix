{
  config,
  lib,
  self,
  ...
}:
{
  imports = with self.modules.nixos; [
    mixin-networking
    mixin-nix
    mixin-openssh
    mixin-sudo
    mixin-terminfo
    mixin-trusted-nix-caches
    mixin-well-known-hosts
  ];

  # Use systemd during boot as well except:
  # - systems with raids as this currently require manual configuration: https://github.com/NixOS/nixpkgs/issues/210210
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = lib.mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);

  # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
  environment.ldso32 = lib.mkDefault null;

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = lib.mkDefault true;

  nix.registry.self.to = {
    type = "path";
    path = self.outPath;
  };
}
