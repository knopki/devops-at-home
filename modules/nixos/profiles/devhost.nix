#
# Development host
#
{ self, ... }:
{
  imports = with self.modules.nixos; [ profiles-workstation ];

  programs.helix = {
    extraPackagesAwk = true;
    extraPackagesCss = true;
    extraPackagesDocker = true;
    extraPackagesHtml = true;
    extraPackagesJq = true;
    extraPackagesLua = true;
    extraPackagesNix = true;
    extraPackagesProtobuf = true;
    extraPackagesPython = true;
    extraPackagesSvelte = true;
    extraPackagesTerraform = true;
    extraPackagesToml = true;
    extraPackagesTypescript = true;
    extraPackagesYaml = true;
  };
}
