{ pkgs, ... }:
pkgs.firefox.override {
  nativeMessagingHosts = with pkgs; [
    keepassxc
  ];
}
