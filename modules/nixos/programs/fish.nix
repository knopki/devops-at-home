{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.lists) optional;
  inherit (lib.strings) optionalString;
  cfg = config.custom.fish;
in
{
  options.custom.fish = {
    enable = mkEnableOption "Apply fish profile";
    enableFzf = mkEnableOption "Enable fzf";
    enableStarship = mkEnableOption "Enable Starship";
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = mkDefault true;
        useBabelfish = mkDefault true;
        interactiveShellInit = optionalString config.programs.vivid.enable ''
          set -gx LS_COLORS "$(${config.programs.vivid.package}/bin/vivid generate ${config.programs.vivid.theme})"
        '';
      };

      fzf = mkIf cfg.enableFzf {
        fuzzyCompletion = mkDefault true;
        keybindings = mkDefault true;
      };

      starship = mkIf cfg.enableStarship {
        enable = mkDefault true;
        transientPrompt.enable = mkDefault true;
      };
    };

    environment.systemPackages = [
      pkgs.fishPlugins.fish-you-should-use
    ]
    ++ optional cfg.enableStarship pkgs.starship;
  };
}
