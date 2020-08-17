{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.direnv = {
    enable = mkEnableOption "create direnvrv with nix shell support";
  };

  config = mkIf config.knopki.direnv.enable {
    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      # use `enableNixDirenvIntegration` when it landed
      stdlib = ''
        source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
      '';
    };
  };
}
