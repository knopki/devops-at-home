final: prev: {
  pass = prev.pass.override {
    waylandSupport = prev.stdenv.hostPlatform.isLinux;
  };
}
