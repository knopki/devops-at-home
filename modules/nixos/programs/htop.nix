{ lib, config, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.custom.htop;
in
{
  options.custom.htop.enable = mkEnableOption "Apply htop profile";

  config = mkIf cfg.enable {
    programs.htop = {
      enable = mkDefault true;
      settings = {
        hide_threads = 1;
        hide_userland_threads = 1;
        shadow_other_users = 1;
        show_program_path = 0;
        show_thread_names = 1;
        highlight_base_name = 1;
        sort_key = 47; # PERCENT_MEM
        left_meters_modes = [
          1
          1
          1
        ];
        left_meters = [
          "AllCPUs"
          "Memory"
          "Swap"
        ];
        right_meters_modes = [
          2
          2
          2
        ];
        right_meters = [
          "Tasks"
          "LoadAverage"
          "Uptime"
        ];
      };
    };
  };
}
