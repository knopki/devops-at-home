{ lib, ... }:
{
  pathToSystemdDeviceName =
    path:
    if path == null || !lib.isString path || !lib.hasPrefix "/" path then
      null
    else
      let
        # remove first /
        s = lib.removePrefix "/" path;
        # 1. replace - with \x2d
        # 2. replace / with -
        escaped = lib.replaceStrings [ "-" "/" ] [ "\\x2d" "-" ] s;
      in
      "${escaped}.device";
}
