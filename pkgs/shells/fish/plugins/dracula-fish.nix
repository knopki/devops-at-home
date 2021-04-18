{ srcs, lib, fishPlugins }:
let src = srcs.dracula-fish;
in
fishPlugins.buildFishPlugin {
  inherit src;
  inherit (src) pname version;

  meta = with lib; {
    description = "Dracula Fish theme";
    homepage = "https://github.com/dracula/fish";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
