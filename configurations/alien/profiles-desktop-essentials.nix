{
  lib,
  pkgs,
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
    };
    kernelParams = [
      "quiet"
      "splash"
      "nohz_full=1-7"
    ];
    tmp.useTmpfs = mkDefault true;
    supportedFilesystems = [ "ntfs" ];
  };

  hardware = {
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
    useNetworkd = true;
  };

  security.protectKernelImage = false;

  services = {
    # avahi = {
    #   nssmdns4 = true;
    #   nssmdns6 = true;
    # };
    dbus.packages = with pkgs; [ dconf ];
    fwupd.enable = false;
    locate = {
      enable = true;
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
