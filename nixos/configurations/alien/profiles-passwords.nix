{ pkgs, packages, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassxc
    pass
  ];

  programs = {
    brave.extensions = [
      # "naepdomgkenhinolocfifgehidddafch" # browserpass
      "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
    ];
  };
}
