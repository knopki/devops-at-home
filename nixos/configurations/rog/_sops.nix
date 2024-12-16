{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
# let
#   defaultSopsFile = {
#     format = "yaml";
#     sopsFile = ./secrets.yaml;
#   };
# in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  # sops = {
  #   defaultSopsFile = ../../../secrets.yaml;
  #   secrets = {
  #     rog-root-user-password = defaultSopsFile // {
  #       key = "root-user-password";
  #       path = "/var/secrets/root-user-password";
  #       neededForUsers = true;
  #     };
  #     rog-knopki-user-password = defaultSopsFile // {
  #       key = "knopki-user-password";
  #       path = "/var/secrets/knopki-user-password";
  #       neededForUsers = true;
  #     };
  #   };
  # };
}
