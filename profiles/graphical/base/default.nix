{ lib, pkgs, ... }:
let inherit (lib) mkDefault genAttrs; in
{
  boot = {
    kernel.sysctl = {
      "kernel.panic" = mkDefault 20;
      "kernel.panic_on_oops" = mkDefault 1;
      "kernel.sysrq" = mkDefault 1;
      "net.ipv4.ip_nonlocal_bind" = mkDefault 1;
      "net.ipv6.ip_nonlocal_bind" = mkDefault 1;
      "vm.panic_on_oom" = mkDefault 1;
    };
    kernelParams = [ "quiet" "splash" "nohz_full=1-7" ];
    tmpOnTmpfs = mkDefault true;
    supportedFilesystems = [ "ntfs" ];
  };

  environment.systemPackages = with pkgs; [
    asciinema
    firefox
    gnupg
    hdparm
    keepassx
    lm_sensors
    mpv
    nmap-graphical
    openssh
    pciutils
    remmina
    transmission-gtk
    unrar
    unzip
    usbutils
    xclip
    xdg_utils
    youtube-dl
  ];

  hardware = {
    opengl = {
      enable = mkDefault true;
      driSupport = mkDefault true;
    };
    pulseaudio.enable = mkDefault true;
    sane = {
      enable = mkDefault true;
      extraBackends = [ ];
    };
  };

  networking = {
    firewall = {
      checkReversePath = mkDefault "loose";
      interfaces =
        let
          # trust at least local docker interfaces
          trustInterfaces = [ "docker0" "br_xod_default" ];
          allowedAllPortRanges = genAttrs
            [ "allowedUDPPortRanges" "allowedTCPPortRanges" ]
            (name: [{ from = 1; to = 65535; }]);
        in
        (genAttrs trustInterfaces (name: allowedAllPortRanges));
    };
    networkmanager = {
      enable = mkDefault true;
      dns = "systemd-resolved";
    };
    useNetworkd = true;
    wireguard.enable = true;
  };

  programs = {
    adb.enable = true;
    chromium.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  security.protectKernelImage = false;

  services = {
    avahi = {
      enable = true;
      nssmdns = true;
    };
    dbus.packages = with pkgs; [ gnome3.dconf ];
    flatpak.enable = true;
    fwupd.enable = true;
    locate = {
      enable = true;
      localuser = null;
      locate = pkgs.mlocate;
      pruneBindMounts = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ cups-kyocera gutenprint ];
    };
    resolved.enable = true;
    xserver = {
      enable = true;
      libinput.enable = true;
    };
  };
}
