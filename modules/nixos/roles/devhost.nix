#
# Devhost role
#
{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.roles.devhost;

  zedEditorFhs = pkgs.zed-editor.fhsWithPackages (
    _ps:
    [
      # ps. prefix - install from the zed-editor's pkgs
      pkgs.package-version-server
    ]
    ++ config.programs.helix.finalExtraPackages
  );
in
{
  imports = with self.modules.nixos; [ role-workstation ];

  options.roles.devhost.enable = mkEnableOption "devhost role";

  config = mkIf cfg.enable {
    roles.workstation.enable = true;

    profiles.applists = {
      admin = mkDefault true;
      adminGUI = mkDefault true;
      dev = mkDefault true;
    };

    environment.systemPackages = [
      zedEditorFhs
    ];

    hardware.flipperzero.enable = mkDefault true;

    programs.adb.enable = true;

    programs.git = {
      enable = true;
      lfs.enable = true;
    };

    programs.helix = {
      extraPackagesCss = true;
      extraPackagesDocker = true;
      extraPackagesFish = true;
      extraPackagesHtml = true;
      extraPackagesJq = true;
      extraPackagesJust = true;
      extraPackagesLua = true;
      extraPackagesNix = true;
      extraPackagesProtobuf = true;
      extraPackagesPython = true;
      extraPackagesSvelte = true;
      extraPackagesSystemd = true;
      extraPackagesTerraform = true;
      extraPackagesToml = true;
      extraPackagesTypescript = true;
      extraPackagesYaml = true;
    };
  };
}
