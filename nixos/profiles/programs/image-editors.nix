{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    digikam
  ];
}
