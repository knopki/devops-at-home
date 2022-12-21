{ inputs, config, lib, pkgs, ... }:
let
  inherit (inputs) digga;
in
{
  hostDefaults = {
    system = "x86_64-linux";
    channelName = "nixos";
    imports = [ (digga.lib.importExportableModules ./modules) ];
    modules = [
      { lib.our = inputs.self.lib; }
      digga.nixosModules.bootstrapIso
      digga.nixosModules.nixConfig
      inputs.home.nixosModules.home-manager
      inputs.agenix.nixosModules.age
      inputs.sops-nix.nixosModules.sops
    ];
  };

  imports = [ (digga.lib.importHosts ./hosts) ];
  hosts = {
    NixOS = { };
    alien = { tests = [ digga.lib.allProfilesTest ]; };
  };
  importables = rec {
    profiles = digga.lib.rakeLeaves ./profiles // {
      users = digga.lib.rakeLeaves ../users;
    };
    suites = with profiles; rec {
      base = [ core users.root ]
        ++ (with cachix; [ nix-community nrdxp ]);

      workstation = base ++ [
        meta.suites.workstation
        desktop.essentials
        desktop.kde
        flatpak
        fonts
        misc.earlyoom
      ] ++ (with programs; [
        chat
        cryptowallets
        downloaders
        image-editors
        image-viewers
        music
        office
        passwords
        remote
        video-editor
        video-player
        web
      ]);

      mobile = base ++ [
        meta.suites.mobile
        laptop
      ];

      devbox = workstation ++ [
        meta.suites.devbox
        ws-virtualization
        dev.nix
      ];

      gamestation = base ++ [
        meta.suites.gamestation
        desktop.essentials
        desktop.kde
        fonts
        misc.earlyoom
        security.disable-mitigations
      ] ++ (with programs; [ downloaders image-viewers video-player music web ]);
    };
  };
}
