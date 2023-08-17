{
  appimageTools,
  pkgs,
  sources,
  ...
}:
appimageTools.wrapType2 rec {
  inherit (sources.framesh) pname src version;
  inherit (pkgs.framesh) meta;
  extraInstallCommands = let
    fs = pkgs.appimageTools.extractType2 {inherit pname version src;};
  in ''
      ln -s $out/bin/${pname}-${version} $out/bin/${pname}
    #   install -m 444 -D ${fs}/frame.desktop $out/share/applications/frame.desktop
      install -m 444 -D ${fs}/frame.png \
        $out/share/icons/hicolor/512x512/apps/frame.png
      substituteInPlace $out/share/applications/frame.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
  '';
}
