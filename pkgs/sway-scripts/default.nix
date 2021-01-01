{ stdenv, pkgs, lib, wrapGAppsHook, makeWrapper, ... }:
with lib;
let
  wofi-systemd = pkgs.rofi-systemd.overrideAttrs (o: rec {
    wrapperPath = with stdenv.lib; makeBinPath (with pkgs; [
      coreutils
      gawk
      jq
      wofi
      systemd
      utillinux
    ]);
    buildInputs = [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      cp -a rofi-systemd $out/bin/wofi-systemd
    '';

    fixupPhase = ''
      patchShebangs $out/bin
      sed -i -E "s/rofi -dmenu/wofi -d/g" $out/bin/wofi-systemd
      sed -i -E "s/ROFI_SYSTEMD_TERM/TERMINAL/g" $out/bin/wofi-systemd
      wrapProgram $out/bin/wofi-systemd --prefix PATH : "${wrapperPath}"
    '';
  });
  internalPath = stdenv.lib.makeBinPath (
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
      nodePackages.emoj
      procps
      slurp
      sway-contrib.grimshot
      sway-unwrapped
      systemd
      wl-clipboard
      wofi
      wofi-systemd
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

  meta = with stdenv.lib; {
    description = "A helpers for sway wm environment";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
