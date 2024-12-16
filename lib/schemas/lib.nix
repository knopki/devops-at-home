{ ... }:
{
  version = 1;
  doc = ''
    The `lib` flake output defines Nix functions.
  '';
  inventory =
    output:
    let
      recurse = attrs: {
        children = builtins.mapAttrs (
          attrName: attr:
          if builtins.isFunction attr then
            {
              # Tell `nix flake show` what this is.
              what = "library function";
              # Make `nix flake check` enforce our naming convention.
              evalChecks.camelCase = builtins.match "^[a-z][a-zA-Z]*$" attrName == [ ];
            }
          else if builtins.isAttrs attr then
            # Recurse into nested sets of functions.
            recurse attr
          else
            throw "unsupported 'lib' type"
        ) attrs;
      };
    in
    recurse output;
}
