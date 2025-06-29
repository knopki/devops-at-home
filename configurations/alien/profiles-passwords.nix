{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  programs = {
    brave.extensions = [
      "oboonakemofpalcgghocfoadofidjkkk" # keepassxc
    ];
  };
}
