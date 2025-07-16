#
# Development host
#
{ self, ... }:
{
  imports = with self.modules.nixos; [ profiles-workstation ];

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
