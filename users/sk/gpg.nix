{ config, nixosConfig, lib, ... }:
let
  inherit (lib) mkMerge;
in
{
  programs = {
    gpg = {
      enable = true;
      settings.default-key = "58A58B6FD38C6B66";
    };
  };

  # use system gpg-agent
  services.gpg-agent.enable = false;

  home.file.".gnupg/gpg-agent.conf".text = ''
    allow-emacs-pinentry
    allow-loopback-pinentry
    allow-preset-passphrase
    default-cache-ttl 2592000
    default-cache-ttl-ssh 2592000
    enable-ssh-support
    max-cache-ttl 2592000
    max-cache-ttl-ssh 2592000
  '';

  # keys to open with pam_gnupg
  home.file.".pam-gnupg".text = ''
    C87C6FBFDA8F3C18CF9BE03F139F5BD50CFB1753 # ${config.programs.gpg.settings.default-key}
    1ABC33EB99591D5F45C2371BD8B89D8551A18A9D # main ssh key
  '';
}
