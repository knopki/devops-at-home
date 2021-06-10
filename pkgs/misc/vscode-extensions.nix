{ vscode-utils, fetchurl, ... }:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
{
  asvetliakov.vscode-neovim = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-neovim";
      publisher = "asvetliakov";
      version = "0.0.81";
      sha256 = "sha256-8mmLuBt0iX9V4xQfphhBAqNi38APmDWp6+xksA4NQ90=";
    };
  };

  pascalsenn.keyboard-quickfix = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "keyboard-quickfix";
      publisher = "pascalsenn";
      version = "0.0.6";
      sha256 = "sha256-BK7ND6gtRVEitxaokJHmQ5rvSOgssVz+s9dktGQnY6M=";
    };
  };

  XadillaX.viml = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "viml";
      publisher = "XadillaX";
      version = "1.0.1";
      sha256 = "sha256-mzf2PBSbvmgPjchyKmTaf3nASUi5/S9Djpoeh0y8gH0=";
    };
  };
}
