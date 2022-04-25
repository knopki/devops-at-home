{ pkgs, lib, ... }:
let inherit (lib) mkDefault mkBefore; in
{
  environment.systemPackages = with pkgs; [ ];

  programs.steam.enable = mkDefault true;

  # 32-bit support needed for steam
  hardware.opengl.driSupport32Bit = mkDefault true;
  hardware.pulseaudio.support32Bit = mkDefault true;

  # better for steam proton games
  systemd.extraConfig = mkBefore "DefaultLimitNOFILE=1048576";

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };
}
