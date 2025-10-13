{ self, ... }:
{
  nixpkgs.config = self.lib.nixpkgsPolicies.configStandard;
}
