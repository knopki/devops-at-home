{ self, ... }:
{
  nixpkgs.overlays = with self.overlays; [
    unstable-backports
    mpv
  ];
  nixpkgs.config = self.lib.nixpkgsPolicies.configStandard;
}
