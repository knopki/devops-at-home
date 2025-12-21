{
  pkgs,
  name ? "cosmic-notify-send",
  ...
}:
pkgs.writeShellApplication {
  inherit name;

  runtimeInputs = [
    pkgs.bash
    pkgs.glib # gdbus
  ];

  text = builtins.readFile ./cosmic-notify-send.sh;

  meta = {
    description = "notify-send compatible wrapper for COSMIC DE using gdbus";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
    mainProgram = "cosmic-notify-send";
  };
}
