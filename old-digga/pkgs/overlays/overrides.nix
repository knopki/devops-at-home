channels: final: prev: {
  __dontExport = true; # overrides clutter up actual creations

  # inherit pkg from other channel like this:
  # > inherit (channels.unstable) some-pkg-name;

  # anytype = let
  #     name = "Anytype-${version}";
  #     inherit (final.sources.anytype) pname version src;
  #     appimageContents = prev.appimageTools.extractType2 { inherit name src; };
  #   in prev.appimageTools.wrapType2 rec {
  #     inherit name src;
  #     extraPkgs = pkgs: (prev.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
  #       ++ [ pkgs.libsecret ];
  #     extraInstallCommands = ''
  #       mv $out/bin/${name} $out/bin/${pname}
  #       source "${prev.makeWrapper}/nix-support/setup-hook"
  #       wrapProgram $out/bin/${pname} \
  #         --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  #       install -m 444 -D ${appimageContents}/anytype.desktop -t $out/share/applications
  #       substituteInPlace $out/share/applications/anytype.desktop \
  #         --replace 'Exec=AppRun' 'Exec=${pname}'
  #       for size in 16 32 64 128 256 512 1024; do
  #         install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/anytype.png \
  #           $out/share/icons/hicolor/''${size}x''${size}/apps/anytype.png
  #       done
  #     '';
  #     meta = prev.anytype.meta;
  # };

  framesh = prev.appimageTools.wrapType2 rec {
    inherit (final.sources.framesh) pname version src;
    meta = prev.framesh.meta;
    extraInstallCommands = let
      fs = prev.appimageTools.extractType2 {inherit pname version src;};
    in ''
      ln -s $out/bin/${pname}-${version} $out/bin/${pname}
      install -m 444 -D ${fs}/frame.desktop $out/share/applications/frame.desktop
      install -m 444 -D ${fs}/frame.png \
        $out/share/icons/hicolor/512x512/apps/frame.png
      substituteInPlace $out/share/applications/frame.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };

  ledger-live-desktop = prev.appimageTools.wrapType2 rec {
    inherit (final.sources.ledger-live-desktop) pname version src;
    meta = prev.ledger-live-desktop.meta;
    extraInstallCommands = let
      fs = prev.appimageTools.extractType2 {inherit pname version src;};
    in ''
      mv $out/bin/${pname}-${version} $out/bin/${pname}
      install -m 444 -D ${fs}/ledger-live-desktop.desktop $out/share/applications/ledger-live-desktop.desktop
      install -m 444 -D ${fs}/ledger-live-desktop.png $out/share/icons/hicolor/1024x1024/apps/ledger-live-desktop.png
      ${prev.imagemagick}/bin/convert ${fs}/ledger-live-desktop.png -resize 512x512 ledger-live-desktop_512.png
      install -m 444 -D ledger-live-desktop_512.png $out/share/icons/hicolor/512x512/apps/ledger-live-desktop.png
      substituteInPlace $out/share/applications/ledger-live-desktop.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };

  # stupid elisp-tree-sitter use old shitty tree sitter
  # see: https://github.com/NixOS/nixpkgs/issues/209114
  tree-sitter-grammars =
    prev.tree-sitter-grammars
    // {
      tree-sitter-python = prev.tree-sitter-grammars.tree-sitter-python.overrideAttrs (_: {
        nativeBuildInputs = [final.nodejs final.tree-sitter];
        configurePhase = ''
          tree-sitter generate --abi 13 src/grammar.json
        '';
      });
    };
}
