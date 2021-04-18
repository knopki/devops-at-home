{ srcs, lib, fishPlugins }:
let src = srcs.fish-kubectl-completions;
in
fishPlugins.buildFishPlugin {
  inherit src;
  inherit (src) pname version;

  meta = with lib; {
    description = "kubectl fish completions";
    homepage = "https://github.com/evanlucas/fish-kubectl-completions";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
