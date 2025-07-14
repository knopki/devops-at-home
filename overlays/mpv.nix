final: prev: {
  mpv-with-plugins = prev.mpv.override {
    scripts = with final.mpvScripts; [
      final.mpvScripts.builtins.autoload
      thumbfast
      uosc
    ];
  };
}
