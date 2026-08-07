{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeBinaryWrapper,
  nix-update-script,
  # runtime libs (CEF / Chromium / Tauri)
  gcc,
  zlib,
  alsa-lib,
  xdotool,
  libx11,
  libxtst,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  dbus,
  wayland,
  glib,
  gtk3,
  gdk-pixbuf,
  pango,
  cairo,
  atk,
  at-spi2-atk,
  at-spi2-core,
  nss,
  nspr,
  cups,
  libgbm,
  libxkbcommon,
  expat,
  systemd, # libudev.so.1
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openhuman-desktop";
  version = "0.63.9";

  src =
    let
      inherit (finalAttrs) version;
      arch = if stdenvNoCC.hostPlatform.isx86_64 then "amd64" else "arm64";
    in
    fetchurl {
      url = "https://github.com/tinyhumansai/openhuman/releases/download/v${version}/OpenHuman_${version}_${arch}.deb";
      hash =
        if stdenvNoCC.hostPlatform.isx86_64 then
          "sha256-sSiq3eEsdHtJP1EWHZiN5avksMUvIrRHb8XFhMC5RTI="
        else
          "sha256-YrjgxYMbYVyLXBoCOw0rhwvZ0C2HG95SLWW+B+6DGDo=";
    };

  # deb layout is bin/, share/OpenHuman, lib/OpenHuman as siblings — keep that
  # geometry under $out so the app's exe-relative resource resolution matches
  # upstream (it ships CEF + .pak/.dat resources beside the binary).
  strictDeps = true;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [
    gcc.cc.lib
    zlib
    alsa-lib
    xdotool
    libx11
    libxtst
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    dbus
    wayland
    glib
    gtk3
    gdk-pixbuf
    pango
    cairo
    atk
    at-spi2-atk
    at-spi2-core
    nss
    nspr
    cups
    libgbm
    libxkbcommon
    expat
    systemd
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    # chrome-sandbox is a setuid CEF helper; the build sandbox can't restore
    # its suid bit and tar fails on chmod. NixOS uses kernel user namespaces
    # for sandboxing instead of the SUID helper, so we exclude it outright.
    # ponytail: if the app ever errors "Operation not permitted" on render,
    # pass --no-sandbox to the wrapper or enable kernel unprivileged userns.
    dpkg-deb --fsys-tarfile "$src" | tar -x --exclude='*/chrome-sandbox'
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    cp -r usr/. $out/

    # replace upstream's /usr/bin/OpenHuman symlink with a proper wrapper;
    # name it openhuman-desktop so it doesn't collide with openhuman-core's
    # `openhuman` CLI when both are installed.
    rm -f $out/bin/OpenHuman
    makeBinaryWrapper $out/share/OpenHuman/OpenHuman $out/bin/openhuman-desktop

    # .desktop: point Exec at our wrapper, keep upstream ozone flags
    install -Dm444 $out/share/applications/OpenHuman.desktop $out/share/applications/openhuman.desktop
    rm -f $out/share/applications/OpenHuman.desktop
    substituteInPlace $out/share/applications/openhuman.desktop \
      --replace-fail "Exec=OpenHuman" "Exec=openhuman-desktop"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "OpenHuman desktop app — local-first AI memory, agent orchestration and research (Tauri + CEF)";
    homepage = "https://github.com/tinyhumansai/openhuman";
    changelog = "https://github.com/tinyhumansai/openhuman/releases/tag/v${finalAttrs.version}";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "openhuman-desktop";
  };
})
