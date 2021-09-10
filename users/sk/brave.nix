{ pkgs, ... }:
{
  programs.browserpass.enable = true;
  programs.brave = {
    extensions = [
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
      { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # tempermonkey
      { id = "jhnleheckmknfcgijgkadoemagpecfol"; } # auto tab discard
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
      { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # i don't care about cookies
      { id = "nibjojkomfdiaoajekhjakgkdhaomnch"; } # ipfs companion
      { id = "oldceeleldhonbafppcapldpdifcinji"; } # languagetool
      { id = "dneaehbmnbhcippjikoajpoabadpodje"; } # old reddit redirect
      { id = "kkkjlfejijcjgjllecmnejhogpbcigdc"; } # org capture
      { id = "dhhpefjklgkmgeafimnjhojgjamoafof"; } # save page we
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium

      { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # metamask
      { id = "mopnmbcafieddcagagdcbnhejhlodfdd"; } # polkadot-js
      { id = "lpilbniiabackdjcionkobglmddfbcjo"; } # waves keeper
      # { id = "nhnkbkgjikgcigadomkphalanndcapjk"; } # clover wallet
      { id = "aiifbnbfobpmeekipheeijimdpnlpgpp"; } # terra station
      { id = "dmkamcknogkgcdfhhbddcghachkejeap"; } # keplr
      { id = "bfnaelmomeimhlpmgjnjophhpkkoljpa"; } # phantom
      { id = "fnnegphlobjdpkhecapkijjdkgcjhkib"; } # harmony wallet
      { id = "cfbfdhimifdmdehjmkdobpcjfefblkjm"; } # plug (icp)
      { id = "fhbohimaelbohpjbbldcngcnapndodjp"; } # binance wallet
    ];
  };

  programs.kde.settings.kdeglobals.General.BrowserApplication = "brave-browser.desktop";
}
