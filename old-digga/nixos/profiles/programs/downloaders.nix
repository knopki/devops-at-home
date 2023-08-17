{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    youtube-dl
  ];
}
