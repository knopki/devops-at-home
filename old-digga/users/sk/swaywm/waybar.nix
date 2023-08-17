{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}: let
  inherit (lib) mkIf;
  waybarReloadCmd = ''
    echo "Reloading mako"
    XDG_RUNTIME_DIR=/run/user/$UID $DRY_RUN_CMD systemctl --user restart waybar
  '';
  waybar-ipcountry = pkgs.writeScript "waybar-ipcountry" ''
    #!/usr/bin/env bash
    CODE=$(curl -s http://ifconfig.co/country-iso)
    echo "{ \"class\": \"$CODE\", \"text\": \"$CODE\" }"
  '';
in {
  home.packages = with pkgs; [
    libappindicator-gtk3 # tray icons support
  ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.override {pulseSupport = true;};
    settings = [
      (
        {
          modules-left = ["sway/workspaces" "sway/mode" "sway/window"];
          modules-center = [];
          modules-right = [
            "tray"
            "idle_inhibitor"
            "cpu"
            "temperature"
            "memory"
            "custom/ipcountry"
            "network"
            "pulseaudio"
            "clock"
          ];
          modules = {
            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = "";
                deactivated = "";
              };
            };
            cpu = {
              states = {critical = 75;};
              format = "{usage}% ";
              tooltip = false;
            };
            memory = {
              format = "{}% ";
              states = {critical = 90;};
            };
            temperature =
              {
                format = "{temperatureC}°C ";
                critical-threshold = 80;
              }
              // (
                if (nixosConfig.networking.hostName == "alien")
                then {
                  hwmon-path = "/sys/class/hwmon/hwmon0/temp1_input";
                }
                else {}
              );
            battery = {
              states = {
                "awesome" = 90;
                "good" = 80;
                "warning" = 30;
                "critical" = 15;
              };
              format = "{capacity}% {icon}";
              format-icons = ["" "" "" "" ""];
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-alt = "{time} {icon}";
              format-awesome = "";
            };
            "custom/ipcountry" = {
              exec = waybar-ipcountry;
              return-type = "json";
              interval = 60;
              tooltip = false;
            };
            network = {
              format-wifi = "{essid} ({signalStrength}%) ";
              tooltip-format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
              format-linked = "{ifname} (No IP) ";
              format-disconnected = "Disconnected ⚠";
              format-alt = " {bandwidthUpBits}↑ {bandwidthDownBits}↓";
              tooltip-format = "{ifname}: {ipaddr}/{cidr}";
            };
            pulseaudio = {
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              format-icons = {
                headphones = "";
                handsfree = "";
                headset = "";
                default = ["" "" ""];
              };
              on-click = "pavucontrol";
              scroll-step = 0.001;
            };
            backlight = {
              format = "{percent}% {icon}";
              format-icons = ["" ""];
            };
            clock = {
              format = " {:%a, %d. %b  %H:%M}";
              tooltip = false;
            };
            "sway/workspaces" = {
              disable-scroll = true;
              format = "{name}: {icon}";
              format-icons = {
                # "1" = "";
                # "2" = "";
                # "3" = "";
                # "4" = "";
                # "5" = "";
                "urgent" = "";
                "focused" = "";
                "default" = "";
              };
            };
            "sway/mode" = {format = ''<span style="italic">{}</span>'';};
            "sway/window" = {max-length = 100;};
          };
        }
        // (
          if (nixosConfig.networking.hostName == "alien")
          then {
            modules-right = [
              "tray"
              "idle_inhibitor"
              "cpu"
              "temperature"
              "memory"
              "battery"
              "custom/ipcountry"
              "network"
              "pulseaudio"
              "backlight"
              "clock"
            ];
          }
          else {}
        )
      )
    ];
    systemd.enable = true;
    style = builtins.readFile ./waybar.css;
  };

  xdg.configFile."waybar/config".onChange =
    mkIf config.programs.waybar.systemd.enable waybarReloadCmd;
  xdg.configFile."waybar/style.css".onChange =
    mkIf config.programs.waybar.systemd.enable waybarReloadCmd;
}
