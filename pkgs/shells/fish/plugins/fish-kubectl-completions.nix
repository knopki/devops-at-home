{ sources, lib, fishPlugins }:
fishPlugins.buildFishPlugin {
  inherit (sources.fish-kubectl-completions) pname version src;

  meta = with lib; {
    description = "kubectl fish completions";
    homepage = "https://github.com/evanlucas/fish-kubectl-completions";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
