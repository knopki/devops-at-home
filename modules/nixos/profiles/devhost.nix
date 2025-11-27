#
# Development host
#
{
  self,
  pkgs,
  config,
  ...
}:
let
  adminTools = with pkgs; [
    anydesk
    remmina
  ];
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
  imports = with self.modules.nixos; [ profile-workstation ];

  environment.systemPackages = [
    zedEditorFhs
  ]
  ++ adminTools;

  hardware = {
    flipperzero.enable = true;
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
}
