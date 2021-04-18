{ users, profiles, userProfiles, ... }:
let
  markSuite = n: { default = { meta.suites.${n} = true; }; };
in
{
  system = with profiles; rec {
    base = [
      core.essentials
      core.locale
      core.nix
      core.sops
      users.root
      misc.journald
    ];

    workstation = base ++ [
      (markSuite "workstation")
      earlyoom
      graphical.base
      graphical.crypto
      graphical.fonts
      graphical.graphical
      graphical.kde
      graphical.im
      graphical.music
      graphical.office
    ];

    stationary = base ++ [
      (markSuite "stationary")
    ];

    mobile = base ++ [
      (markSuite "mobile")
      laptop
    ];

    devbox = workstation ++ [
      (markSuite "devbox")
      dev.nix
      dev.virt
    ];

    gamestation = base ++ [
      (markSuite "gamestation")
      graphical.fonts
      graphical.games
      graphical.kde
      misc.disable-mitigations
    ];
  };

  user = with userProfiles; rec {
    base = [
      curl
      essential
      fish
      fixes
      fzf
      git
      htop
      readline
      sensible-vim
      ssh
      tmux
      wget
    ];

    graphical = base ++ [
      chromium
      firefox
      gnome
      zathura
    ];

    workstation = base ++ [
      password-store
      russophilia
      starship
      vscode
    ];

    devbox = workstation ++ [
      dev
    ];

    gamestation = graphical ++ [
      russophilia
    ];
  };
}
