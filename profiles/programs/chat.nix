{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    discord
    rocketchat-desktop
    skypeforlinux
    tdesktop
    zoom-us
  ];
}
