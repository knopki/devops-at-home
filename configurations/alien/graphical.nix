{ pkgs, ... }:
let
  officeSuite = with pkgs; [
    citations
    dialect
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
      eyedropper
    ])
    ++ officeSuite;
}
