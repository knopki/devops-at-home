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
    config-locale
    config-nix
    config-zswap
    program-htop
    program-ssh-well-known-hosts
    security-sudo
    service-networking
    service-openssh
  ];

  custom.htop.enable = mkDefault true;
  custom.locale.enable = mkDefault true;
  custom.networking.enable = mkDefault true;
  custom.nix.enable = mkDefault true;
  custom.openssh.enable = mkDefault true;
  custom.ssh-well-known-hosts.enable = mkDefault true;
  custom.sudo.enable = mkDefault true;

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

  custom.zswap = {
    enable = (builtins.length config.swapDevices) > 0 && !config.zramSwap.enable;
    compressor = mkDefault "lz4";
    max_pool_percent = mkDefault 20;
    shrinker_enabled = mkDefault true;
    same_filled_pages = mkDefault true;
  };

  environment.enableAllTerminfo = true;

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
