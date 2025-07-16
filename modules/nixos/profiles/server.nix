#
# Some server host
#
{ self, ... }:
{
  imports = with self.modules.nixos; [ programs-helix ];

  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
