{ inputs, self, ... }:
inputs.nixpkgs-25-05.lib.nixosSystem {
  specialArgs = {
    inherit inputs self;
  };
  modules = [
    "${inputs.nixpkgs-25-05.outPath}/nixos/modules/installer/cd-dvd/installation-cd-minimal-combined.nix"
    "${inputs.nixpkgs-25-05.outPath}/nixos/modules/installer/cd-dvd/channel.nix"
    ./configuration.nix
    {
      networking.hostName = "iso";
      isoImage.squashfsCompression = "lz4 -b 32768";
      nixpkgs.hostPlatform = "x86_64-linux";
    }
  ];
}
