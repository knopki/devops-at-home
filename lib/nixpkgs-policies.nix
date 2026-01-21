{
  lib,
  ...
}:
let
  inherit (builtins) any elem;
  inherit (lib) getName;
  inherit (lib.strings) hasPrefix;

  allowUnfreeAndroidPredicate =
    pkg:
    let
      name = getName pkg;
      description = (pkg.meta or { }).description or "";
    in
    any (prefix: hasPrefix prefix description) [
      "Android SDK tools"
      "Official IDE for Android"
      "The Official IDE for Android"
    ]
    || any (prefix: hasPrefix prefix name) [
      "android-studio"
    ];

  allowUnfreeNamePredicate =
    pkg:
    elem (getName pkg) [
      "anydesk"
      "aspell-dict-en-science"
      "discord"
      "obsidian"
      "terraform"
      "yandex-cloud"
    ];

  allowUnfreePredicateStandard = pkg: allowUnfreeNamePredicate pkg || allowUnfreeAndroidPredicate pkg;

  allowInsecurePkgVersPredicate =
    pkg:
    elem "${pkg.pname}-${pkg.version}" [
      "ecdsa-0.19.1" # python3.12
    ];
  allowInsecurePredicateStandard = pkg: allowInsecurePkgVersPredicate pkg;

  allowlistedLicenses = with lib.licenses; [
    unfreeRedistributable
  ];
  blocklistedLicenses = [ ];
in
{
  inherit
    allowUnfreeAndroidPredicate
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
