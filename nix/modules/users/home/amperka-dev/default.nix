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
  gloudEnvAliasing = ''
    export GOOGLE_CLOUD_KEYFILE_JSON=$GOOGLE_CREDENTIALS
    export GCLOUD_KEYFILE_JSON=$GOOGLE_CREDENTIALS
    export CLOUDSDK_COMPUTE_REGION=$GOOGLE_REGION
    export GCLOUD_ZONE=$GOOGLE_ZONE
    export CLOUDSDK_COMPUTE_ZONE=$GOOGLE_ZONE
    export GOOGLE_COMPUTE_ZONE=$GOOGLE_ZONE
    export GOOGLE_CLOUD_PROJECT=$GOOGLE_PROJECT
    export GCLOUD_PROJECT=$GOOGLE_PROJECT
    export CLOUDSDK_CORE_PROJECT=$GOOGLE_PROJECT
    export GOOGLE_PROJECT_ID=$GOOGLE_PROJECT
  '';

  amperkaEnvRC = ''
    use nix

    ${gcloudCommonPreambula}

    export GOOGLE_REGION="EU"
    export GOOGLE_ZONE="europe-west1-b"
    export GOOGLE_PROJECT="amperka-hq"
    export PULUMI_CONFIG_PASSPHRASE=$(pass amperka-hq/pulumi_config_passphrase)

    ${gloudEnvAliasing}
  '';
  xodioEnvRC = ''
    use nix

    ${gcloudCommonPreambula}

    export GOOGLE_REGION="US"
    export GOOGLE_ZONE="us-central1-a"
    export GOOGLE_PROJECT="xodio-146312"

    ${gloudEnvAliasing}
  '';
  homePath = config.home.homeDirectory;
in
{
  options.local.amperka-dev.enable = mkEnableOption "Amperka Dev helpers";

  config = mkIf config.local.amperka-dev.enable {
    home.file."dev/amperka/.envrc".text = amperkaEnvRC;
    home.file."dev/amperka/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/amperka-hq/.envrc".text = amperkaEnvRC;
    home.file."dev/amperka-hq/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/nkrkv/.envrc".text = amperkaEnvRC;
    home.file."dev/nkrkv/shell.nix".source = ./amperka.shell.nix;

    home.file."dev/xodio/.envrc".text = xodioEnvRC;
    home.file."dev/xodio/shell.nix".source = ./xodio.shell.nix;
  };
}
