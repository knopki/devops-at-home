{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.profiles.terminfo;
in
{
  options.profiles.terminfo.enable = mkEnableOption "Enable terminfo profile";

  config = mkIf cfg.enable {
    # various terminfo packages
    environment.systemPackages = [
      pkgs.wezterm.terminfo # this one does not need compilation
      # avoid compiling desktop stuff when doing cross nixos
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
      pkgs.alacritty.terminfo
      pkgs.foot.terminfo
      pkgs.ghostty.terminfo
      pkgs.kitty.terminfo
      pkgs.termite.terminfo
    ];
  };
}
