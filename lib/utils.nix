{ lib, ... }:
let
  inherit (builtins) attrNames elemAt length isAttrs readDir;
  inherit (lib) filterAttrs hasSuffix mapAttrs' nameValuePair removeSuffix splitString;
in
rec {
  # mapFilterAttrs ::
  #   (name -> value -> bool )
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  mapFilterAttrs = seive: f: attrs: filterAttrs seive (mapAttrs' f attrs);

  recImportHosts = { dir, _import }:
    mapFilterAttrs (_: v: v != null) (
      n: v: let
        parts = splitString "." n;
      in
        if v == "regular" && hasSuffix ".nix" n && (length parts) == 3
        then let
          name = elemAt parts 0; system = elemAt parts 1;
        in
          nameValuePair (name) (_import name system)
        else nameValuePair ("") (null)

    ) (readDir dir);

  mkHM = { username, config }: configuration: let
    defaultConfiguration = {
      _module.args = {
        nixosConfig = config;
      };
      home.stateVersion = lib.mkDefault config.system.stateVersion;
      imports = [ ../hm-modules/core.nix ];
    };
    finalConfiguration = {
      "${username}" = { ... }: defaultConfiguration // configuration;
    };
  in
    finalConfiguration;
}
