{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassx
    pass
  ];

  programs = {
    brave.extensions = [ "naepdomgkenhinolocfifgehidddafch" ];
    browserpass.enable = true;
  };
}
