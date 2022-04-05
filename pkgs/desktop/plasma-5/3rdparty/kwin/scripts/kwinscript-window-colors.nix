{ lib, mkDerivation, fetchFromGitHub
, kcoreaddons, kwindowsystem, plasma-framework, systemsettings }:

mkDerivation rec {
  pname = "kwinscript-window-colors";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "psifidotos";
    repo = "kwinscript-window-colors";
    rev = "v${version}";
    sha256 = "sha256-KPKVGk8iCxf52u6Eoi4BAwHBbx0LHiJqbBFCMaIAY3Y=";
  };

  buildInputs = [
    kcoreaddons kwindowsystem plasma-framework systemsettings
  ];

  dontBuild = true;

  # 1. --global still installs to $HOME/.local/share so we use --packageroot
  # 2. plasmapkg2 doesn't copy metadata.desktop into place, so we do that manually
  installPhase = ''
    runHook preInstall
    plasmapkg2 --type kwinscript --install ${src} --packageroot $out/share/kwin/scripts
    install -Dm644 ${src}/metadata.desktop $out/share/kservices5/kwinscript-window-colors.desktop
    runHook postInstall
  '';

  meta = with lib; {
    description = "This is a KWin script that sends window colors information to Latte through dbus interface.";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    inherit (src.meta) homepage;
    inherit (kwindowsystem.meta) platforms;
  };
}
