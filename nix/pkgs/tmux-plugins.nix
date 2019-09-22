self: super:
with import <nixpkgs> { };
let
  versions = builtins.fromJSON (builtins.readFile ./versions.json);

  rtpPath = "share/tmux-plugins";

  addRtp = path: rtpFilePath: attrs: derivation:
    derivation // {
      rtp = "${derivation}/${path}/${rtpFilePath}";
    } // {
      overrideAttrs = f: mkDerivation (attrs // f attrs);
    };

  mkDerivation = a@{ pluginName, rtpFilePath ?
    (builtins.replaceStrings [ "-" ] [ "_" ] pluginName)
    + ".tmux", namePrefix ? "tmuxplugin-", src, unpackPhase ? "", postPatch ?
      "", configurePhase ? ":", buildPhase ? ":", addonInfo ? null, preInstall ?
        "", postInstall ? "", path ?
          (builtins.parseDrvName pluginName).name, dependencies ? [ ], ... }:
    addRtp "${rtpPath}/${path}" rtpFilePath a (super.stdenv.mkDerivation (a // {
      name = namePrefix + pluginName;

      inherit pluginName unpackPhase postPatch configurePhase buildPhase
        addonInfo preInstall postInstall;

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
      src = fetchFromGitHub versions.tmux-colors-solarized;
    };

    tmux-powerline = mkDerivation rec {
      pluginName = "tmux-powerline";
      rtpFilePath = "powerline.sh";
      src = fetchFromGitHub versions.tmux-powerline;
    };
  };
}
