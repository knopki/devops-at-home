{
  inputs,
  mkNixosConfiguration,
  self,
  ...
}:
mkNixosConfiguration {
  inherit (inputs.nixpkgs-25-05.lib) nixosSystem;
  system = "x86_64-linux";
  modules = with self.modules.nixos; [
    # inputs.sops-nix.nixosModules.sops
    # inputs.preservation.nixosModules.preservation
    {
      system.stateVersion = "25.05";
      services.userborn.enable = true;
      users.mutableUsers = false;
      networking.hostId = "b9367b38";
      networking.hostName = "dev-vm";

    }
    ./hardware.nix
    ./inbox.nix
  ];
}
