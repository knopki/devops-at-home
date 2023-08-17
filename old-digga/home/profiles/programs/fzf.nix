{
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = lib.mkDefault true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    fileWidgetOptions = [" --preview 'head {}'"];
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    changeDirWidgetOptions = ["--preview 'tree -C {} | head -200'"];
  };
}
