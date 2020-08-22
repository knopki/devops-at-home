inputs@{ home, nixpkgs, nixpkgsFor, self, ... }:
let
  inherit (builtins) attrValues length removeAttrs;
  inherit (nixpkgs) lib;

  utils = import ../lib/utils.nix { inherit lib; };
  inherit (utils) recImportHosts;

  mkHost = name: system:
    lib.nixosSystem {
      inherit system;

      specialArgs.usr = { inherit utils; };

      modules = let
        # inherit (home.nixosModules) home-manager;

        core = ../profiles/core.nix;

        global = {
          # system.configurationRevision = self.rev
          #   or (throw "Cannot deploy from an unclean source tree!");
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
          networking.hostName = name;
          nix.nixPath = let
            rebuild-throw = nixpkgsFor.${system}.writeText "rebuild-throw.nix"
              ''throw "I'm sorry Dave, I'm afraid I can't do that... Please, use flakes."'';
          in
            [
              "nixpkgs=${nixpkgs}"
              "nixos-config=${rebuild-throw}"
            ];

          nixpkgs = { pkgs = nixpkgsFor.${system}; };
        };

        local = import "${toString ./.}/${name}.${system}.nix";

        # Everything in `./modules/list.nix`.
        flakeModules =
          attrValues (removeAttrs self.nixosModules [ "profiles" "home-manager" ]);

      in
        flakeModules ++ [ core global local "${home}/nixos" ];
    };

  hosts = recImportHosts { dir = ./.; _import = mkHost; };
in
hosts
