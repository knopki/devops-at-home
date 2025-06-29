{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
in
{
  options.meta.suites = {
    workstation = mkEnableOption "workstation suite activated";
    stationary = mkEnableOption "stationary suite activated";
    mobile = mkEnableOption "mobile suite activated";
    devbox = mkEnableOption "devbox suite activated";
    gamestation = mkEnableOption "gamestation suite activated";
  };
}
