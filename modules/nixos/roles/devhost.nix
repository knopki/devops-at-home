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
    ++ config.custom.helix.finalExtraPackages
  );
in
{
  imports = with self.modules.nixos; [ role-workstation ];

  options.roles.devhost.enable = mkEnableOption "devhost role";

  config = mkIf cfg.enable {
    roles.workstation.enable = true;

    custom.applists = {
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

    programs.direnv.enable = true;

    custom.helix = {
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

    programs.mosh.enable = true;

    programs.nix-index.enable = mkDefault true;

    programs.nix-ld = {
      enable = mkDefault true;
      # see https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/nix-ld.nix
      # default list of included libraries:
      #  zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2
      #  libxml2 acl libsodium util-linux xz systemd
      libraries = [ ];
    };

    services.envfs.enable = mkDefault true;
  };
}
