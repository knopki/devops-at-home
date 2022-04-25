{ config, lib, ... }:
with config.lib.htop;
{
  programs.htop = {
    enable = lib.mkDefault true;
    settings = {
      hide_threads = true;
      hide_userland_threads = true;
      shadow_other_users = true;
      show_program_path = false;
      show_thread_names = true;
      sort_key = fields.PERCENT_MEM;
      highlight_base_name = true;
    } // (leftMeters [
      (bar "AllCPUs")
      (bar "Memory")
      (bar "Swap")
    ]) // (rightMeters [
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
    ]);
  };
}
