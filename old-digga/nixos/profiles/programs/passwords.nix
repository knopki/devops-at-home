{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    pass
  ];

  programs = {
    brave.extensions = ["naepdomgkenhinolocfifgehidddafch"];
    browserpass.enable = true;
  };
}
