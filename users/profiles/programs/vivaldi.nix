{ lib, pkgs, ... }:
let
  superProprietaryVivaldi = pkgs.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = true;
  };
in
{
  programs.vivaldi = {
    enable = lib.mkDefault true;
    package = lib.mkDefault superProprietaryVivaldi;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
    ];
  };
}
