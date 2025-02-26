{
  lib,
  pkgs,
  packages,
  ...
}:
let
  inherit (lib) mkDefault genAttrs;
in
{
  boot = {
    kernel.sysctl = {
      "kernel.panic" = mkDefault 20;
      "kernel.panic_on_oops" = mkDefault 1;
      "kernel.sysrq" = mkDefault 1;
      "net.ipv4.ip_nonlocal_bind" = mkDefault 1;
      "net.ipv6.ip_nonlocal_bind" = mkDefault 1;
      "vm.panic_on_oom" = mkDefault 1;
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
    kernelParams = [
      "quiet"
      "splash"
      "nohz_full=1-7"
    ];
    tmp.useTmpfs = mkDefault true;
    supportedFilesystems = [ "ntfs" ];
  };

  environment.systemPackages = with pkgs; [
    asciinema
    gnupg
    hdparm
    lm_sensors
    nmap
    pciutils
    trashy
    unrar
    unzip
    usbutils
    xclip
    xdg-utils
  ];

  hardware = {
    graphics.enable = mkDefault true;
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
          trustInterfaces = [
            "docker0"
            "br_xod_default"
          ];
          allowedAllPortRanges =
            genAttrs
              [
                "allowedUDPPortRanges"
                "allowedTCPPortRanges"
              ]
              (_name: [
                {
                  from = 1;
                  to = 65535;
                }
              ]);
        in
        (genAttrs trustInterfaces (_name: allowedAllPortRanges));
    };
    networkmanager.enable = mkDefault true;
    useNetworkd = true;
  };

  programs = {
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableBrowserSocket = true;
    };
    ssh = {
      startAgent = true;
    };
  };

  security.protectKernelImage = false;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
    dbus.packages = with pkgs; [ dconf ];
    fwupd.enable = false;
    locate = {
      enable = true;
      localuser = null;
      package = pkgs.mlocate;
      pruneBindMounts = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        pantum-driver
      ];
    };
    resolved.dnssec = "false";
    xserver.enable = true;
    libinput.enable = true;
  };
}
