{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    khard
    khal
  ];

  xdg.configFile = {
    "khard/khard.conf".text = ''
      [addressbooks]
      [[contacts]]
      path = ~/.local/share/contacts/private

      [contact table]
      display = formatted_name
      show_uids = no
      show_kinds = yes
      sort = formatted_name
      localize_dates = no

      [vcard]
      preferred_version = 4.0
    '';
    "khal/config".text = ''
      [default]
      default_calendar = private
      highlight_event_days = True
      print_new = event
      timedelta = 14d

      [locale]
      dateformat = %Y-%m-%d
      datetimeformat = %Y-%m-%d %H:%M
      firstweekday = 1
      default_timezone = Europe/Moscow

      [calendars]
        [[private]]
          path = ~/.local/share/calendars/private
          color = dark green
          priority = 20
        [[ann]]
          path = ~/.local/share/calendars/family
          color = dark gray
          priority = 5
    '';
  };
}
