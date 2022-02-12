{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
  ];

  programs.brave = {
    enable = true;
  };
}
