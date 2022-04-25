{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    deltachat-desktop
    discord
    element-desktop
    rocketchat-desktop
    skypeforlinux
    tdesktop
    zoom-us
  ];
}
