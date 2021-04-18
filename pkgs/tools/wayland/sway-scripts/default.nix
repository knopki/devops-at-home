{ stdenv, pkgs, lib, wrapGAppsHook, makeWrapper, ... }:
let
  inherit (lib) makeBinPath licenses platforms;
  internalPath = makeBinPath (
    with pkgs; [
      (pass.withExtensions (ext: with ext; [ pass-otp ]))
      coreutils
      findutils
      gawk
      gnugrep
      gnused
      graphicsmagick-imagemagick-compat
      grim
      jq
      libnotify
      procps
      slurp
      sway-contrib.grimshot
      sway-unwrapped
      systemd
      wl-clipboard
      wofi
      xdg_utils
    ]
  );
in
stdenv.mkDerivation rec {
  name = "sway-scripts";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    mkdir ${name}
    cp -R $src/bin ${name}/
  '';

  installPhase = ''
    for file in $(ls ${name}/bin); do
        name=$(basename $file .sh)
        install -Dm0755 ${name}/bin/$file $out/bin/$name
        wrapProgram $out/bin/$name --set PATH "${internalPath}"
    done
  '';

  meta = {
    description = "A helpers for sway wm environment";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
