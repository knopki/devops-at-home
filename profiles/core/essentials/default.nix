{ config, lib, pkgs, ... }:
let inherit (lib) mkDefault; in
{
  imports = [ ../../cachix ];

  # common packages on all machines (very opionated)
  # merged with `requiredPackages' from
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/system-path.nix
  environment.systemPackages = with pkgs; [
    binutils
    curl
    dnsutils
    dosfstools
    fd
    file
    gitMinimal
    gnupg
    gptfdisk
    iputils
    lsof
    neovim
    ngrep
    pstree
    ranger
    ripgrep
    rmlint
    rsync
    sysstat
    tree
    wget
    whois
  ];

  environment.shellAliases =
    let ifSudo = lib.mkIf config.security.sudo.enable;
    in
    {
      # nix
      n = "nix";
      np = "n profile";
      ni = "np install";
      nr = "np remove";
      ns = "n search --no-update-lock-file";
      nf = "n flake";
      nepl = "n repl '<nixpkgs>'";
      srch = "ns nixos";
      orch = "ns override";
      nrb = ifSudo "sudo nixos-rebuild";

      # fix nixos-option
      nixos-option = "nixos-option -I nixpkgs=${toString ../../lib/compat}";
    };

  networking = {
    firewall = {
      rejectPackets = true;
    };
  };

  programs = {
    command-not-found.enable = mkDefault false;
    fish.enable = mkDefault true;
    iftop.enable = mkDefault true;
    iotop.enable = mkDefault true;
    mosh.enable = mkDefault true;
    mtr.enable = mkDefault true;
    tmux.enable = mkDefault true;
  };

  security = {
    polkit.extraConfig = ''
      /* Allow users in wheel group to manage systemd units without authentication */
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.isInGroup("wheel")) {
              return polkit.Result.YES;
          }
      });
    '';

    protectKernelImage = mkDefault true;

    sudo.extraConfig = ''
      Defaults timestamp_type=global,timestamp_timeout=600
    '';
  };

  services = {
    openssh = {
      enable = mkDefault true;
      passwordAuthentication = mkDefault false;
      startWhenNeeded = mkDefault true;
    };

    timesyncd.servers = mkDefault [ "time.cloudflare.com" ];
  };

  systemd.linger.enable = true;

  users.defaultUserShell = pkgs.fish;
}
