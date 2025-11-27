# Temporary configuration that should go away
# Remove or move to modules/other files
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3
  ];

  programs = {
    bat.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
