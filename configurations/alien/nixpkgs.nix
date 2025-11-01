{ self, inputs, ... }:
{
  disabledModules = [
    "services/display-managers/cosmic-greeter.nix"
    "services/desktop-managers/cosmic.nix"
    "services/desktops/geoclue2.nix"
  ];

  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/display-managers/cosmic-greeter.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/desktop-managers/cosmic.nix"
    "${inputs.nixpkgs-unstable}/nixos/modules/services/desktops/geoclue2.nix"
  ];

  nixpkgs.overlays = with self.overlays; [
    unstable-backports
    mpv
  ];
  nixpkgs.config = self.lib.nixpkgsPolicies.configStandard;
}
