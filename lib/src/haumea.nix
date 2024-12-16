{ lib, haumea, ... }:
let
  inherit (builtins)
    attrValues
    filter
    foldl'
    isAttrs
    isPath
    length
    ;
  inherit (lib.trivial) mergeAttrs pipe;
  inherit (lib.attrsets)
    mapAttrs'
    mapAttrsToList
    nameValuePair
    recursiveUpdate
    ;
in
rec {
  loaders = haumea.lib.loaders // { };

  transformers = haumea.lib.transformers // {
    /**
      If a directory contains default.nix, raise it and ignore all other modules
      in that directory.
      @author: Weathercold
      @license: MIT
    */
    raiseDefault = _: v: v.default or v;

    /**
      Use parent directory path for `default.nix`. This is because nix treats
      these two paths as different modules and doesn't deduplicate if both are
      imported.
      @author: Weathercold
      @license: MIT
    */
    removeDefaultSuffix = _: v: if isPath v && baseNameOf v == "default.nix" then dirOf v else v;

    /**
      For pkgs/by-name
      @author: Weathercold
      @license: MIT
    */
    callPackage =
      pkgs: ks: v:
      if
        length ks == 0 # root
      then
        pipe v [
          attrValues
          (filter isAttrs)
          (foldl' mergeAttrs { })
        ]
      else if length ks == 2 && v ? package then
        pkgs.callPackage v.package { }
      else
        v;

    /**
      Flatten the attribute set by concatenating the keys. Useful for
      nixosModules and homeModules.
      @author: Weathercold
      @license: MIT
    */
    flatten =
      _: v1:
      if isAttrs v1 then
        pipe v1 [
          (mapAttrsToList (
            k2: v2:
            if isAttrs v2 then mapAttrs' (k3: v3: nameValuePair "${k2}-${k3}" v3) v2 else { ${k2} = v2; }
          ))
          (foldl' recursiveUpdate { })
        ]
      else
        v1;
  };
}
