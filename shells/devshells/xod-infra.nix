{
  config,
  pkgs,
  ...
}:

{
  devshell.name = "xod infra";

  devshell.packages = with pkgs; [
    curl
    gcrane
    gnumake
    kubectl
    rclone
    terraform
    terraform-docs
    terraform-ls
    terragrunt
    tflint
    qemu-utils
    (google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
  ];
}
