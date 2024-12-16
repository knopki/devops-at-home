{
  lib,
  haumea,
  super,
  ...
}:
let
  inherit (lib.attrsets) attrValues isAttrs mapAttrs;
in
rec {
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
    Return an attribute set of all modules under a directory, prepending
    subdirectory names to keys. If there is a default.nix in a directory, it is
    *raised* and all other modules in that directory are ignored.
    @author: Weathercold
    @license: MIT
  */
  toModuleAttr =
    src:
    haumea.lib.load {
      inherit src;
      loader = haumea.lib.loaders.path;
      transformer = with super.haumea.transformers; [
        raiseDefault
        removeDefaultSuffix
        flatten
      ];
    };

  /**
    Like `toModuleAttr`, but also prepend the root directory name to keys.
    @author: Weathercold
    @license: MIT
  */
  toModuleAttr' =
    src: super.haumea.transformers.flatten [ ] { ${baseNameOf src} = toModuleAttr src; };

  /**
    Like `toModuleAttr`, but all modules are imported.
  */
  toImportedModuleAttr = args: src: mapAttrs (_: value: import value args) (toModuleAttr src);

  /**
    Like `toModuleAttr'`, but all modules are imported.
  */
  toImportedModuleAttr' = args: src: mapAttrs (_: value: import value args) (toModuleAttr' src);

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
