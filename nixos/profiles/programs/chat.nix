{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    element-desktop
    rocketchat-desktop
    skypeforlinux
    zoom-us
  ];
}
