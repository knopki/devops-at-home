{ config, lib, pkgs, user, ... }:
with lib;
let
  gcloudCommonPreambula = ''
    export GOOGLE_APPLICATION_CREDENTIALS="${config.home.homeDirectory}/.config/gcloud/application_default_credentials.json"
    if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
      gcloud auth application-default login
    fi
    export GOOGLE_CREDENTIALS=$(cat $GOOGLE_APPLICATION_CREDENTIALS)
  '';
  amperkaEnvRC = ''
    use nix

    ${gcloudCommonPreambula}

    export GOOGLE_REGION="EU"
    export GOOGLE_ZONE="europe-west1-b"
    export GOOGLE_PROJECT="amperka-hq"
    export PULUMI_CONFIG_PASSPHRASE=$(pass amperka-hq/pulumi_config_passphrase)
  '';
  xodioEnvRC = ''
    use nix

    ${gcloudCommonPreambula}

    export GOOGLE_REGION="US"
    export GOOGLE_ZONE="us-central1-a"
    export GOOGLE_PROJECT="xodio-146312"

    layout go
  '';

  sourcesNix = ../../../../sources.nix;
  sourcesJsonPath = pkgs.writeText "sources.json" (readFile ../../../../sources.json);
  # inject json path to sources.nix
  sourcesNixStr = replaceStrings
    [ "./sources.json" ]
    [ "${sourcesJsonPath}" ]
    (readFile sourcesNix);
  sourcesNixPath = pkgs.writeText "sources.nix" sourcesNixStr;
  sourcesTargetDir = ".cache/nix-sources";
  sources = import sourcesNix;
  # prepend shells with sources.nix import
  preludeStr = "sources = import ${sourcesNixPath};";

  amperkaShellStr = replaceStrings
    [ "include = 1;" ]
    [ preludeStr ]
    (readFile ./amperka.shell.nix);
  amperkaShellPath = pkgs.writeText "amperka.shell.nix" amperkaShellStr;

  xodioShellStr = replaceStrings
    [ "include = 1;" ]
    [ preludeStr ]
    (readFile ./xodio.shell.nix);
  xodioShellPath = pkgs.writeText "xodio.shell.nix" xodioShellStr;
in
{
  options.local.amperka-dev.enable = mkEnableOption "Amperka Dev helpers";

  config = mkIf config.local.amperka-dev.enable {
    # create links just to prevent GC
    home.file."${sourcesTargetDir}/sources.json".source = sourcesJsonPath;
    home.file."${sourcesTargetDir}/sources.nix".source = sourcesNixPath;

    home.file."dev/amperka/.envrc".text = amperkaEnvRC;
    home.file."dev/amperka/shell.nix".source = amperkaShellPath;

    home.file."dev/amperka-hq/.envrc".text = amperkaEnvRC;
    home.file."dev/amperka-hq/shell.nix".source = amperkaShellPath;

    home.file."dev/nkrkv/.envrc".text = amperkaEnvRC;
    home.file."dev/nkrkv/shell.nix".source = amperkaShellPath;

    home.file."dev/xodio/.envrc".text = xodioEnvRC;
    home.file."dev/xodio/shell.nix".source = xodioShellPath;
  };
}
