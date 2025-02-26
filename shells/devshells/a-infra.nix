{ pkgs, ...}:

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
    yc
  ];
}
