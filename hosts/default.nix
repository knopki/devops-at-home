inputs@{ home, nixpkgs, nixpkgsFor, sops-nix, self, ... }:
let
  inherit (builtins) attrNames attrValues elem length mapAttrs removeAttrs;
  inherit (nixpkgs) lib;
  inherit (nixpkgs.lib) filterAttrs mkMerge traceVal;

  utils = import ../lib/utils.nix { inherit lib; };
  inherit (utils) recImportHosts;

  mkHost = name: system:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        usr = { inherit utils; };
      };

      modules =
        let
          core = ../profiles/core.nix;

          global = {
            imports = import ../users/list.nix;

            networking.hostName = name;

            # add all flake inputs as flake registries
            nix.registry =
              let
                ignoredInputNames = [ "self" "nixpkgsFor" ];
                safeInputNames = attrNames
                  (filterAttrs (k: v: !elem k ignoredInputNames) inputs);
                registryOpts = mkMerge (map
                  (name: {
                    "${name}".flake = inputs."${name}";
                  })
                  safeInputNames);
              in
              registryOpts // { devops-at-home.flake = inputs.self; };

            nixpkgs = { pkgs = nixpkgsFor.${system}; };

            # system.configurationRevision = self.rev
            #   or (throw "Cannot deploy from an unclean source tree!");
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };

          local = import "${toString ./.}/${name}.${system}.nix";

          # Everything in `./modules/list.nix`.
          flakeModules =
            attrValues (removeAttrs self.nixosModules [ "profiles" "home-manager" ]);

        in
        flakeModules ++ [
          core
          global
          local
          home.nixosModules.home-manager
          sops-nix.nixosModules.sops
        ];
    };

  hosts = recImportHosts { dir = ./.; _import = mkHost; };
in
hosts
