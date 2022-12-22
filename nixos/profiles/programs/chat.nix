{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    element-desktop
    rocketchat-desktop
    zoom-us
  ];
}
