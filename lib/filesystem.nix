{
  lib,
  haumea,
  ...
}: let
  inherit
    (lib.attrsets)
    attrValues
    collect
    isAttrs
    mapAttrsToList
    mapAttrs'
    nameValuePair
    recursiveUpdate
    ;
  inherit (lib.lists) foldl';
  inherit (lib.trivial) pipe;
in rec {
  haumeaLoaders = haumea.lib.loaders // {};

  haumeaTransformers =
    haumea.lib.transformers
    // {
      # If a directory contains default.nix, raise it and ignore all other
      # modules in that directory.
      # stolen from @Weathercold
      # like liftDefault but `default` is optional
      raiseDefault = _: v: v.default or v;
      # Collect the values into a flat list
      # stolen from @Weathercold
      toList = _: v:
        if isAttrs v
        then lib.flatten (attrValues v)
        else [v];
      # Flatten the attribute set by concatenating the keys. Useful for
      # nixosModules and homeManagerModules
      # stolen from @Weathercold
      flatten = _: v1:
        if isAttrs v1
        then
          pipe v1 [
            (
              mapAttrsToList
              (
                k2: v2:
                  if isAttrs v2
                  then mapAttrs' (k3: v3: nameValuePair "${k2}-${k3}" v3) v2
                  else {${k2} = v2;}
              )
            )
            (foldl' recursiveUpdate {})
          ]
        else v1;
    };

  # Represent a directory as a tree of paths to nix modules.
  toModuleTree = {...} @ args:
    haumea.lib.load ({loader = haumeaLoaders.path;} // args);

  # List paths of all modules under a directory. If there is a default.nix in a
  # directory, it is *raised* and all other modules in that directory are
  # ignored.
  toModuleList = {...} @ args:
    haumea.lib.load ({
        loader = haumeaLoaders.path;
        transformer = with haumeaTransformers; [raiseDefault toList];
      }
      // args);

  # Return an attribute set of all modules under a directory, prepending
  # subdirectory names to keys. If there is a default.nix in a directory, it is
  # *raised* and all other modules in that directory are ignored.
  toModuleAttr = {...} @ args:
    haumea.lib.load ({
        loader = haumeaLoaders.path;
        transformer = with haumeaTransformers; [raiseDefault flatten];
      }
      // args);

  # Like `toModuleAttr`, but also prepend the root directory name to keys.
  toModuleAttr' = {src, ...} @ args:
    haumeaTransformers.flatten [] {${baseNameOf src} = toModuleAttr args;};
}
