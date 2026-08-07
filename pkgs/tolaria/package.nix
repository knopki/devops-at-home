{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeBinaryWrapper,
  writeShellScript,
  # runtime libs (Tauri / webkit2gtk)
  gcc,
  openssl,
  glib,
  gtk3,
  cairo,
  gdk-pixbuf,
  dbus,
  webkitgtk_4_1,
  libsoup_3,
  gsettings-desktop-schemas, # org.gnome.desktop.* — needed by the native file dialog
  # tools spawned at runtime
  nodejs, # MCP server (index.js) + desktop ws-bridge
  desktop-file-utils, # update-desktop-database — REQUIRED by deep-link setup hook
  xdg-utils, # xdg-mime — tolaria:// URL handler registration
  zenity, # rfd (Rust File Dialog) backend for the vault-folder picker
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    inherit (finalAttrs) version;
    # Upstream tags are vYYYY-MM-DD (zero-padded) while the deb version is
    # YYYY.M.D — derive the tag from the version so there is a single source
    # of truth for the download URL.
    parts = lib.splitString "." version; # [ "2027" "7" "31" ]
    tagVersion = lib.concatStringsSep "-" [
      (builtins.elemAt parts 0)
      (lib.strings.fixedWidthString 2 "0" (toString (lib.toIntBase10 (builtins.elemAt parts 1))))
      (lib.strings.fixedWidthString 2 "0" (toString (lib.toIntBase10 (builtins.elemAt parts 2))))
    ];
    tag = "v${tagVersion}";
  in
  {
    pname = "tolaria";
    version = "2027.7.31";

    src = fetchurl {
      url = "https://github.com/refactoringhq/tolaria/releases/download/${tag}/Tolaria_${version}_amd64.deb";
      hash = "sha256-mnbpLeUXPLcB4XxBR9yXZlESuoX9V57A2Ahphoi4Qdo=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3 # GSettings schemas + XDG_DATA_DIRS + GI typelibs for the desktop binary
      makeBinaryWrapper # tolaria-mcp-server wrapper
    ];

    buildInputs = [
      gcc.cc.lib
      openssl
      glib
      gtk3
      cairo
      gdk-pixbuf
      dbus.lib
      webkitgtk_4_1
      libsoup_3
      gsettings-desktop-schemas
    ];

    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      # deb geometry: usr/bin/tolaria (exe) + usr/lib/Tolaria/{agent-docs,mcp-server}.
      # The Tauri binary resolves ws-bridge.js and its resources relative to its
      # own exe, so the upstream usr/ layout must be kept intact under $out.
      dpkg-deb --fsys-tarfile "$src" | tar -x
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      cp -r usr/. $out/

      # .desktop: absolute Exec path so it launches even when the package is not
      # on PATH.
      substituteInPlace $out/share/applications/Tolaria.desktop \
        --replace-fail "Exec=tolaria" "Exec=$out/bin/tolaria"

      runHook postInstall
    '';

    preFixup = ''
      # Augment wrapGAppsHook3's auto-computed args (schemas/XDG_DATA_DIRS) with
      # the tools the Tauri app spawns at runtime.
      #   - update-desktop-database (desktop-file-utils): the deep-link setup hook
      #     runs it at launch and propagates its absence as a hard ENOENT panic.
      #   - node: lets the desktop spawn ws-bridge.js so external MCP clients can
      #     talk to the active vault.
      #   - xdg-utils: registers the tolaria:// scheme handler.
      #   - zenity: rfd (Rust File Dialog) spawns it for the vault-folder picker.
      # WEBKIT_DISABLE_DMABUF_RENDERER works around the well-known WebKitGTK GPU
      # rendering bug on NixOS (UI collapses to a ~1px sliver). --set-default so a
      # user with a working DMA-BUF path can override it in their environment.
      gappsWrapperArgs+=(
        --prefix PATH : ${
          lib.makeBinPath [
            desktop-file-utils
            xdg-utils
            nodejs
            zenity
          ]
        }
        --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1
      )
    '';

    postFixup = ''
      # Created after wrapGAppsHook3 has wrapped the desktop binary (fixupPhase),
      # so this node wrapper is not itself re-wrapped.
      #
      # MCP server entrypoint for external clients (Claude Code, Cursor, ...).
      # index.js is a bundled CommonJS script needing node 18+; it talks to the
      # running desktop via WS_UI_PORT.
      makeBinaryWrapper ${nodejs}/bin/node $out/bin/tolaria-mcp-server \
        --append-flags $out/lib/Tolaria/mcp-server/index.js
    '';

    # Custom updater: the download URL carries the date in two formats
    # (vYYYY-MM-DD in the tag path, YYYY.M.D in the deb name), so nix-update's
    # single token substitution can't rewrite both. We pin the latest
    # *stable* release via the GitHub API instead.
    passthru.updateScript = writeShellScript "update-tolaria" ''
      set -euo pipefail
      PKG_NIX="pkgs/tolaria/package.nix"

      META=$(curl -fsSL 'https://api.github.com/repos/refactoringhq/tolaria/releases?per_page=100')
      LATEST=$(jq -r '[.[] | select(.prerelease == false and .draft == false)] | sort_by(.published_at) | last' <<<"$META")

      ASSET=$(jq -r '.assets[] | select(.name | test("_amd64\\.deb$")) | .name' <<<"$LATEST")
      URL=$(jq -r '.assets[] | select(.name | test("_amd64\\.deb$")) | .browser_download_url' <<<"$LATEST")
      NEW_VERSION=$(sed -E 's/^Tolaria_(.+)_amd64\.deb$/\1/' <<<"$ASSET")

      NEW_HASH=$(nix-prefetch-url --type sha256 "$URL" | xargs nix hash convert --to sri --hash-algo sha256)

      # version is the single source of truth — the vYYYY-MM-DD tag is derived
      # from it in package.nix, so only version + hash need touching.
      sed -i -E "s|  version = \".*\";|  version = \"$NEW_VERSION\";|" "$PKG_NIX"
      sed -i -E "s|    hash = \".*\";|    hash = \"$NEW_HASH\";|" "$PKG_NIX"

      echo "tolaria: $NEW_VERSION ($NEW_HASH)"
    '';

    meta = with lib; {
      description = "Tolaria — personal knowledge and life management app (Tauri + webkit2gtk)";
      homepage = "https://github.com/refactoringhq/tolaria";
      changelog = "https://github.com/refactoringhq/tolaria/releases/tag/${tag}";
      license = licenses.agpl3Only;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "tolaria";
    };
  }
)
