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

  custom = {
    htop.enable = mkDefault true;
    locale.enable = mkDefault true;
    networking.enable = mkDefault true;
    nix.enable = mkDefault true;
    openssh.enable = mkDefault true;
    ssh-well-known-hosts.enable = mkDefault true;
    sudo.enable = mkDefault true;
  };

  # Use systemd during boot as well except:
  # - systems with raids as this currently require manual configuration: https://github.com/NixOS/nixpkgs/issues/210210
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = mkDefault true;

  environment = {
    # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
    ldso32 = mkDefault null;

    enableAllTerminfo = true;

    # Man cache is very slow to rebuild
    # Remove non-needed man pages to speed up rebuild
    extraSetup = /* bash */ ''
      # remove multilanguage man pages
      find "$out/share/man" \
      -mindepth 1 -maxdepth 1 \
      -not -name "man[1-8]" \
      -exec rm -r "{}" ";"
      # remove man section 3 which contains mainly C functions
      rm -rf "$out/share/man/man3"
    '';
  };

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
}
