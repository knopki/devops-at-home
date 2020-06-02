{ pkgs, lib, newScope, recurseIntoAttrs, ... }:
lib.makeScope newScope (
  self: with self; let
    packagePlugin = callPackage ./package-plugin.nix {};
    callPackages = lib.callPackagesWith (pkgs // self // { inherit packagePlugin; });
  in
    {
      completions = recurseIntoAttrs (callPackages ./completions {});

      pure = packagePlugin rec {
        name = "fish-pure-${version}";
        version = "2.5.2";
        src = pkgs.fetchFromGitHub {
          owner = "rafaelrinaldi";
          repo = "pure";
          rev = "d66aa7f0fec5555144d29faec34a4e7eff7af32b";
          sha256 = "0klcwlgsn6nr711syshrdqgjy8yd3m9kxakfzv94jvcnayl0h62w";
        };
        meta.license = lib.licenses.mit;
      };
    }
)
