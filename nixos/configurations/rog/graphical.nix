{
  pkgs,
  ...
}:
{

  environment.gnome.excludePackages = with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    geary # email reader
    gedit # text editor
    gnome-characters
    gnome-music
    gnome-photos
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
  ];

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gnome-themes-extra
  ];

  programs.dconf.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;

    # xserver.displayManager.gdm.enable = true;
    # xserver.desktopManager.gnome.enable = true;
    udev.packages = with pkgs; [ gnome-settings-daemon ];
  };
}
