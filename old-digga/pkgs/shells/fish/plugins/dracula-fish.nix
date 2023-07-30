{ sources, lib, fishPlugins }:
let src = sources.dracula-fish;
in
fishPlugins.buildFishPlugin {
  inherit (sources.dracula-fish) pname version src;

  meta = with lib; {
    description = "Dracula Fish theme";
    homepage = "https://github.com/dracula/fish";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
