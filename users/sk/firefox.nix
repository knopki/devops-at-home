{ pkgs, lib, config, ... }:
{
  programs.firefox = {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      # TODO: polkadot
      # TODO: waves-keeper
      auto-tab-discard
      browserpass
      buster-captcha-solver
      bypass-paywalls
      i-dont-care-about-cookies
      ipfs-companion
      languagetool
      metamask
      multi-account-containers
      no-pdf-download
      old-reddit-redirect
      org-capture
      react-devtools
      save-page-we
      tree-style-tab
      tridactyl
      ublock-origin
      violentmonkey
    ];

    profiles.default.settings = { };
  };

  xdg.configFile."tridactyl/tridactylrc".text = ''
    " Smooth scrolling, yes please. This is still a bit janky in Tridactyl.
    set smoothscroll true

    " The default jump of 10 is a bit much.
    bind j scrollline 5
    bind k scrollline -5

    set newtab about:blank
    set tabopencontainerware true
    set editorcmd ${config.home.sessionVariables.VISUAL}
  '';
}
