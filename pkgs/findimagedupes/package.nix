{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule {
  pname = "findimagedupes";
  version = "0-unstable-2023-11-09";
  src = fetchFromGitHub {
    owner = "swenson";
    repo = "findimagedupes";
    rev = "4adb1f42c22ca8031e0f3eecea0a1df7200a0a74";
    fetchSubmodules = false;
    sha256 = "sha256-WejJdCzpEUmhKggBk469HsFs/IVuxdhUZ/93V8I0eNg=";
  };

  vendorHash = null;

  passthru.updateScript = [ ./update.sh ];

  meta = with lib; {
    description = "findimagedupes";
    homepage = "https://github.com/swenson/findimagedupes";
    license = licenses.gpl3;
    platforms = platforms.all;
    inherit version;
  };
}
