{
  pass,
  stdenv,
  ...
}:
pass.override {
  waylandSupport = stdenv.hostPlatform.isLinux;
}
