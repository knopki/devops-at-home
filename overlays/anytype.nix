final: prev: {
  anytype = prev.anytype.override {
    waylandSupport = prev.stdenv.hostPlatform.isLinux;
    src = prev.fetchurl {
      url = "https://at9412003.fra1.digitaloceanspaces.com/Anytype-0.20.9.AppImage";
      name = "Anytype-0.20.9.AppImage";
      sha256 = "sha256-dm3bdKbUHI0FFcyYeYd2XSuZuoPsUhk4KcEwzPHiHM8=";
    };
  };
}
