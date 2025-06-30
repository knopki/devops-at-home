{
  lib,
  haumea,
  super,
  ...
}:
let
  inherit (lib.attrsets) attrValues isAttrs;
in
{
  haumeaLoaders = haumea.lib.loaders // super.haumea.loaders;

  haumeaTransformers =
    haumea.lib.transformers
    // super.haumea.transformers
    // {
      # Collect the values into a flat list
      # stolen from @Weathercold
      toList = _: v: if isAttrs v then lib.flatten (attrValues v) else [ v ];
    };

  # Represent a directory as a tree of paths to nix modules.
  # toModuleTree = {...} @ args:
  #   haumea.lib.load ({loader = haumeaLoaders.path;} // args);
  #

  /**
    Return an attrset of packages under a directory with the pkgs/by-name
    structure.
    @author: Weathercold
    @license: MIT
  */
  toPackages =
    pkgs: src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = super.haumea.transformers.callPackage pkgs;
    };
}
