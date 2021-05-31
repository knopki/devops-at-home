{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassx
    pass
  ];
}
