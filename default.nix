# A function so that this can be imported like nixpkgs by various update scripts and nixpkgs-hammering.
{
  # Required by nixpkgs-hammering.
  overlays ? [ ],
  ...
}:

let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake-compat = fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
    sha256 = lock.nodes.flake-compat.locked.narHash;
  };
  self = import flake-compat {
    src = ./.;
  };
  nixpkgs = import self.defaultNix.inputs.nixpkgs.outPath { };

  packages = self.defaultNix.outputs.legacyPackages.${builtins.currentSystem};
  packagesWithExtraOverlays = nixpkgs.appendOverlays (
    [ self.defaultNix.outputs.overlays.default ] ++ overlays
  );
in
# Prepend all packages for current system so that
# various update scripts and nixpkgs-hammering
# can find the packages without having to recurse into outputs.
packagesWithExtraOverlays // packages // self.defaultNix
