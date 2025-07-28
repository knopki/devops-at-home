{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  imports = [
    self.modules.nixos.programs-helix
  ];

  environment.systemPackages = map lib.lowPrio [
    # no config.programs.git.package option on darwin
    (config.programs.git.package or pkgs.gitMinimal)
    pkgs.curl
    pkgs.dnsutils
    pkgs.htop
    pkgs.jq
    pkgs.tmux
  ];

  programs = {
    git.package = lib.mkDefault pkgs.gitMinimal;

    helix = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
