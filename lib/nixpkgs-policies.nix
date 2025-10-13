{
  lib,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) getName;

  mkPkgPredicate =
    names: nameVersions: pkg:
    (elem (getName pkg) names) || (elem "${pkg.pname}-${pkg.version}" nameVersions);

  allowedUnfreeDesktopPackages = [
    "anydesk"
    "aspell-dict-en-science"
    "discord"
    "obsidian"
  ];

  allowedUnfreePackages = [
    "pantum-driver"
    "terraform"
  ]
  ++ allowedUnfreeDesktopPackages;
  allowedUnfreePackageVersions = [ ];

  allowUnfreePredicateStandard = mkPkgPredicate allowedUnfreePackages allowedUnfreePackageVersions;

  allowedInsecurePackages = [ ];
  allowedInsecurePackageVersions = [
    # "electron-35.7.5"
  ];

  allowInsecurePredicateStandard = mkPkgPredicate allowedInsecurePackages allowedInsecurePackageVersions;

  allowlistedLicenses = with lib.licenses; [
    unfreeRedistributable
  ];
  blocklistedLicenses = [ ];
in
{
  inherit
    allowUnfreePredicateStandard
    allowInsecurePredicateStandard
    allowlistedLicenses
    blocklistedLicenses
    ;

  configStandard = {
    inherit allowlistedLicenses blocklistedLicenses;
    allowUnfreePredicate = allowUnfreePredicateStandard;
    allowInsecurePredicate = allowInsecurePredicateStandard;

    android_sdk.accept_license = true;
  };
}
