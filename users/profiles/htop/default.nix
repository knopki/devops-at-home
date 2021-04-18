{ config, ... }:
with config.lib.htop;
{
  programs.htop = {
    enable = true;
    settings = {
      hide_threads = true;
      hide_userland_threads = true;
      shadow_other_users = true;
      show_program_path = false;
      show_thread_names = true;
      sort_key = fields.PERCENT_MEM;
      highlight_base_name = true;
      right_meter_modes = [ "Tasks" "LoadAverage" "Uptime" ];
    } // (leftMeters {
      AllCPUs = modes.Bar;
      Memory = modes.Bar;
      Swap = modes.Bar;
    }) // (rightMeters {
      Tasks = modes.Text;
      LoadAverage = modes.Text;
      Uptime = modes.Text;
    });
  };
}
