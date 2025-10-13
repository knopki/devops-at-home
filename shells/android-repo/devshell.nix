{ pkgs, ... }:
let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # toolsVersion = "36.0.0";
    # platformToolsVersion = "36.0.0";
    # buildToolsVersions = [ "36.0.0" ];
    # platformVersions = [ "36" ];
    # cmakeVersions = [ "3.18.1" ];
    # ndkVersion = "22.1.7171670";
  };
  myPython = pkgs.python312.withPackages (ps: [ ps.androguard ]);
in
{
  devshell.name = "android-repo";

  devshell.packages = with pkgs; [
    androidComposition.platform-tools
    apkeep
    fdroidcl
    fdroidserver
    jdk
    myPython
    rclone
  ];

  env = [
    {
      name = "ANDROID_HOME";
      value = "${androidComposition.androidsdk}";
    }
    {
      name = "ANDROID_SDK_ROOT";
      value = "${androidComposition.androidsdk}/libexec/android-sdk";
    }
    {
      name = "ANDROID_NDK_ROOT";
      value = "${androidComposition.androidsdk}/ndk-bundle";
    }
  ];
}
