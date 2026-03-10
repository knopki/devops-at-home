{
  pkgs,
  name ? "zabor",
  ...
}:
pkgs.writeShellApplication {
  inherit name;

  runtimeInputs = [
    pkgs.bubblewrap
    pkgs.landrun
    pkgs.util-linux
  ];

  text = builtins.readFile ./zabor.sh;

  meta = {
    description = "Safe sandbox runner for dangerous tools";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
    mainProgram = "zabor";
  };
}
