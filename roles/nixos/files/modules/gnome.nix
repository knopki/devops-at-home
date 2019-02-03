{pkgs, ...}:
with builtins;
{
  environment.gnome3.excludePackages = with pkgs; [
    epiphany
    gnome3.accerciser
    gnome3.gnome-documents
    gnome3.evolution
    gnome3.gnome-music
    gnome3.gnome-software
    gnome3.totem
  ];

  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
  ];

  programs = {
    dconf.enable = true;
  };

  services = {
    dbus.packages = with pkgs; [ gnome3.dconf ];
    gnome3.gnome-keyring.enable = true;
    xserver = {
      desktopManager.gnome3.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };
  };
}
