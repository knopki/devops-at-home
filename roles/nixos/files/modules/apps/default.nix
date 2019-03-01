{ pkgs, ... }:
{
  imports =
  [

  ];

  # common packages on all machines
  environment.systemPackages = with pkgs; [
    bat
    curl
    fd
    file
    fish
    fish-foreign-env
    fish-theme-pure
    fzf
    gnupg
    htop
    iftop
    iotop
    jq
    pinentry
    pinentry_ncurses
    pstree
    python3 # required by ansible
    ripgrep
    rsync
    sysstat
    wget
  ];
}
