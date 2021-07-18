{ pkgs, lib, config, ... }:
{
  programs.firefox = {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      # TODO: polkadot
      # TODO: waves-keeper
      auto-tab-discard
      browserpass
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

    " Search helpers
    bind / fillcmdline find
    bind ? fillcmdline find -?
    bind n findnext +1
    bind N findnext -1

    set newtab about:blank
    set tabopencontainerware true
    set editorcmd ${config.home.sessionVariables.VISUAL}
  '';
}
