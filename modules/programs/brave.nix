{ config, lib, ... }:

with lib;

let
  cfg = config.programs.brave;

  defaultProfile = filterAttrs (k: v: v != null) {
    HomepageLocation = cfg.homepageLocation;
    DefaultSearchProviderSearchURL = cfg.defaultSearchProviderSearchURL;
    DefaultSearchProviderSuggestURL = cfg.defaultSearchProviderSuggestURL;
    ExtensionInstallForcelist = cfg.extensions;
  };
in

{
  ###### interface

  options = {
    programs.brave = {
      enable = mkEnableOption "<command>brave</command> policies";

      extensions = mkOption {
        type = types.listOf types.str;
        description = ''
          List of brave extensions to install.
          For list of plugins ids see id in url of extensions on
          <link xlink:href="https://chrome.google.com/webstore/category/extensions">chrome web store</link>
          page. To install a chromium extension not included in the chrome web
          store, append to the extension id a semicolon ";" followed by a URL
          pointing to an Update Manifest XML file. See
          <link xlink:href="https://cloud.google.com/docs/chrome-enterprise/policies/?policy=ExtensionInstallForcelist">ExtensionInstallForcelist</link>
          for additional details.
        '';
        default = [];
        example = literalExpression ''
          [
            "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
            "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
            "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
            "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
          ]
        '';
      };

      homepageLocation = mkOption {
        type = types.nullOr types.str;
        description = "Brave default homepage";
        default = null;
        example = "https://nixos.org";
      };

      defaultSearchProviderSearchURL = mkOption {
        type = types.nullOr types.str;
        description = "Brave default search provider url.";
        default = null;
        example =
          "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
      };

      defaultSearchProviderSuggestURL = mkOption {
        type = types.nullOr types.str;
        description = "Brave default search provider url for suggestions.";
        default = null;
        example =
          "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
      };

      extraOpts = mkOption {
        type = types.attrs;
        description = ''
          Extra chromium policy options. A list of available policies
          can be found in the Chrome Enterprise documentation:
          <link xlink:href="https://cloud.google.com/docs/chrome-enterprise/policies/">https://cloud.google.com/docs/chrome-enterprise/policies/</link>
          Make sure the selected policy is supported on Linux and your browser version.
        '';
        default = {};
        example = literalExpression ''
          {
            "BrowserSignin" = 0;
            "SyncDisabled" = true;
            "PasswordManagerEnabled" = false;
            "SpellcheckEnabled" = true;
            "SpellcheckLanguage" = [
                                     "de"
                                     "en-US"
                                   ];
          }
        '';
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.etc."brave/policies/managed/default.json".text = builtins.toJSON defaultProfile;
    environment.etc."brave/policies/managed/extra.json".text = builtins.toJSON cfg.extraOpts;
  };
}
