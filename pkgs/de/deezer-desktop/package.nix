{
  pkgs,
  lib,
  appimageTools,
  makeWrapper,
  commandLineArgs ? "",
  stdenv,
  fetchurl,
  nix-update-script,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "deezer-desktop";
  version = "6.0.150-1";
  src =
    fetchurl
      {
        x86_64-linux = {
          url = "https://github.com/aunetx/deezer-linux/releases/download/v6.0.150-1/deezer-desktop-6.0.150-x86_64.AppImage";
          hash = "sha256-+i/Xki1/aoymgBrYJxfuZi+PURmCh8SjUNJGGSdQrPw=";
        };
        aarch64-linux = {
          url = "https://github.com/aunetx/deezer-linux/releases/download/v6.0.150-1/deezer-desktop-6.0.150-arm64.AppImage";
          hash = "sha256-XWeorWoi1BV+EW61IHpU20GYZoIQDuTIHoxB/D1cio8=";
        };
      }
      .${system} or throwSystem;

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraPkgs = pkgs: [ pkgs.libsecret ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/${pname}.png -t $out/share/pixmaps/
    substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "An universal linux port of deezer";
    homepage = "https://github.com/aunetx/deezer-linux";
    license = licenses.unfree;
    mainProgram = "deezer-linux";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
