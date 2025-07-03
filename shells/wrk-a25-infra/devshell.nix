{ pkgs, ... }:

{
  devshell.name = "a* infra";

  devshell.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
    curl
    docker
    doctl
    gcrane
    gnumake
    podman
    rclone
    terraform
    terraform-docs
    terraform-ls
    terragrunt
    tflint
    yandex-cloud
  ];

  env = [
    {
      name = "PODMAN_COMPOSE_PROVIDER";
      value = "docker-compose";
    }
    {
      name = "TERRAGRUNT_AUTO_INIT";
      value = "false";
    }
    {
      name = "TG_DOWNLOAD_DIR";
      eval = "$PRJ_DATA_DIR/terragrunt-cache";
    }
    {
      name = "TF_PLUGIN_CACHE_DIR";
      eval = "$PRJ_DATA_DIR/tf-plugin-cache";
    }
  ];
}
