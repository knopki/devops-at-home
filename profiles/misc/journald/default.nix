{ lib, ... }:
{
  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
}
