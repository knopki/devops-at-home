final: prev: {
  firefox-with-keepassxc = prev.firefox.override {
    nativeMessagingHosts = [ final.keepassxc ];
  };
}
