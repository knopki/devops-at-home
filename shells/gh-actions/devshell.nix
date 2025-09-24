{ pkgs, ... }:
{
  devshell.name = "gh-actions";

  devshell.packages = with pkgs; [
    act
  ];
}
