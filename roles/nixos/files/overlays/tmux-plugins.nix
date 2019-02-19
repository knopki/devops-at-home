self: super:
let
  rtpPath = "share/tmux-plugins";

  addRtp = path: rtpFilePath: attrs: derivation:
    derivation // { rtp = "${derivation}/${path}/${rtpFilePath}"; } // {
      overrideAttrs = f: mkDerivation (attrs // f attrs);
    };

  mkDerivation = a@{
    pluginName,
    rtpFilePath ? (builtins.replaceStrings ["-"] ["_"] pluginName) + ".tmux",
    namePrefix ? "tmuxplugin-",
    src,
    unpackPhase ? "",
    postPatch ? "",
    configurePhase ? ":",
    buildPhase ? ":",
    addonInfo ? null,
    preInstall ? "",
    postInstall ? "",
    path ? (builtins.parseDrvName pluginName).name,
    dependencies ? [],
    ...
  }:
    addRtp "${rtpPath}/${path}" rtpFilePath a (super.stdenv.mkDerivation (a // {
      name = namePrefix + pluginName;

      inherit pluginName unpackPhase postPatch configurePhase buildPhase addonInfo preInstall postInstall;

      installPhase = ''
        runHook postPatch
        runHook preInstall
        target=$out/${rtpPath}/${path}
        mkdir -p $out/${rtpPath}
        cp -r . $target
        if [ -n "$addonInfo" ]; then
          echo "$addonInfo" > $target/addon-info.json
        fi
        runHook postInstall
      '';

      dependencies = [ super.bash ] ++ dependencies;
    }));

in rec {
  inherit mkDerivation;

  tmuxPlugins = super.tmuxPlugins // {
    tmux-colors-solarized = mkDerivation rec {
      pluginName = "tmux-colors-solarized";
      rtpFilePath = "tmuxcolors.tmux";
      src = super.fetchgit {
        url = "https://github.com/seebi/tmux-colors-solarized";
        rev = "b74be1f5076240d278e78b6fd132d531d5c41cda";
        sha256 = "1qjm6w00rk5pi1a9l50h1i3x1jys4n8zmmigh2gigcr4r7rgr2jv";
      };
    };

    tmux-powerline = mkDerivation rec {
      pluginName = "tmux-powerline";
      rtpFilePath = "powerline.sh";
      src = super.fetchgit {
        url = "https://github.com/erikw/tmux-powerline";
        rev = "V1.1";
        sha256 = "0zv8f6nmf0x1x59v1jdv7j97cbb78gaqbx4fx5r0i2pd94w5jxps";
      };
    };
  };
}
