{ pkgs, packages, ... }:
{
  environment.systemPackages = with pkgs; [
    packages.keepassxc
    pass
  ];

  programs = {
    brave.extensions = [
      # "naepdomgkenhinolocfifgehidddafch" # browserpass
      "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
    ];
  };
}
