{
  inputs,
  mkNixosConfiguration,
  ...
}:
mkNixosConfiguration {
  inherit (inputs.nixpkgs-24-11.lib) nixosSystem;
  system = "x86_64-linux";
  modules = [
    "${inputs.nixpkgs-24-11.outPath}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${inputs.nixpkgs-24-11.outPath}/nixos/modules/installer/cd-dvd/channel.nix"
    ./configuration.nix
    {
      networking.hostName = "iso";
      isoImage.squashfsCompression = "lz4 -b 32768";
    }
  ];
}
