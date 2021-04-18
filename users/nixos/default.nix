{ ... }:
{
  home-manager.users.nixos = { suites, ... }: {
    imports = suites.base;
  };

  users.users.nixos = {
    uid = 10000;
    password = "nixos";
    description = "default";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
