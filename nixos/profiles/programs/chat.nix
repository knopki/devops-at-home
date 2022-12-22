{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    deltachat-desktop
    element-desktop
    rocketchat-desktop
    skypeforlinux
    zoom-us
  ];
}
