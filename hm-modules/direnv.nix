{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.direnv = {
    enable = mkEnableOption "create direnvrv with nix shell support";
  };

  config = mkIf config.knopki.direnv.enable {
    programs.direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
      stdlib = ''
        use_flake() {
          mkdir -p $(direnv_layout_dir)
          watch_file flake.nix
          watch_file flake.lock
          eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
        }
      '';
    };
  };
}
