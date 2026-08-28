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
        genAttrs trustInterfaces (_name: allowedAllPortRanges);
    };
    useNetworkd = true;
    networkmanager.dispatcherScripts = [
      {
        # https://wiki.archlinux.org/title/NetworkManager#Dynamically_set_NTP_servers_received_via_DHCP_with_systemd-timesyncd
        # You can debug with sudo journalctl -u NetworkManager-dispatcher -e
        # make sure to restart NM as described above
        source = pkgs.writeText "10-update-timesyncd" ''
          [ -z "$CONNECTION_UUID" ] && exit 0
          INTERFACE="$1"
          ACTION="$2"
          case $ACTION in
          up | dhcp4-change | dhcp6-change)
              systemctl restart systemd-timesyncd.service
              if [ -n "$DHCP4_NTP_SERVERS" ]; then
                echo "Will add the ntp server $DHCP4_NTP_SERVERS"
              else
                echo "No DHCP4 NTP available."
                exit 0
              fi
              mkdir -p /etc/systemd/timesyncd.conf.d
              # <<-EOF must really use tabs to keep indentation correct… and tabs are often converted to space in wiki
              # so I don't want to risk strange issues with indentation
              echo "[Time]" > "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              echo "NTP=$DHCP4_NTP_SERVERS" >> "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              systemctl restart systemd-timesyncd.service
              ;;
          down)
              rm -f "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
              systemctl restart systemd-timesyncd.service
              ;;
          esac
          echo 'Done!'
        '';
      }
    ];
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
      ];
    };
    resolved.settings.Resolve.DNSSEC = false;
    xserver.enable = true;
    libinput.enable = true;
  };
}
