{ pkgs, ... }:
{
  devshell.name = "wrk-tld3-abs";

  devshell.packages = with pkgs; [
    just
    # lima
  ];
}
