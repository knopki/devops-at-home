{
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib.modules) mkDefault;
in
{
  imports = with self.modules.nixos; [
    profile-htop
    profile-locale
    profile-networking
    profile-nix
    profile-openssh
    profile-ssh-well-known-hosts
    profile-sudo
    zswap
  ];

  profiles.htop.enable = mkDefault true;
  profiles.locale.enable = mkDefault true;
  profiles.networking.enable = mkDefault true;
  profiles.nix.enable = mkDefault true;
  profiles.openssh.enable = mkDefault true;
  profiles.ssh-well-known-hosts.enable = mkDefault true;
  profiles.sudo.enable = mkDefault true;

  # Use systemd during boot as well except:
  # - systems with raids as this currently require manual configuration: https://github.com/NixOS/nixpkgs/issues/210210
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);

  # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
  environment.ldso32 = mkDefault null;

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = mkDefault true;

  nix.registry.self.to = {
    type = "path";
    path = self.outPath;
  };

  zswap = {
    enable = (builtins.length config.swapDevices) > 0 && !config.zramSwap.enable;
    compressor = mkDefault "lz4";
    max_pool_percent = mkDefault 20;
    shrinker_enabled = mkDefault true;
    same_filled_pages = mkDefault true;
  };

  # Man cache is very slow to rebuild
  # Remove non-needed man pages to speed up rebuild
  environment.extraSetup = /* bash */ ''
    # remove multilanguage man pages
    find "$out/share/man" \
      -mindepth 1 -maxdepth 1 \
      -not -name "man[1-8]" \
      -exec rm -r "{}" ";"
    # remove man section 3 which contains mainly C functions
    rm -rf "$out/share/man/man3"
  '';
}
