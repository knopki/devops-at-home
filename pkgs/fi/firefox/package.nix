{ pkgs, ... }:
pkgs.firefox.override {
  nativeMessagingHosts = with pkgs; [
    browserpass
    plasma-browser-integration
  ];
}
