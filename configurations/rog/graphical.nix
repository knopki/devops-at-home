{ pkgs, ... }:
let
  officeSuite = with pkgs; [
    gImageReader
    naps2
    nextcloud-client
    onlyoffice-desktopeditors
    pdfarranger
  ];
in
{
  environment.systemPackages =
    (with pkgs; [

    ])
    ++ officeSuite;
}
