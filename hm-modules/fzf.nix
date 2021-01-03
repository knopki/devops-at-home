{ config, lib, pkgs, ... }:
with lib;
{
  options.knopki.fzf = { enable = mkEnableOption "enable fzf for user"; };

  config = mkIf config.knopki.fzf.enable {
    programs.fzf = {
      enable = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
      fileWidgetOptions = [ " --preview 'head {}'" ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };
  };
}
