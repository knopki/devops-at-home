{
  lib,
  fetchFromGitHub,
  unstableGitUpdater,
  buildGoModule,
}:
buildGoModule {
  pname = "findimagedupes";
  version = "0-unstable-2023-11-09";
  src = fetchFromGitHub {
    owner = "swenson";
    repo = "findimagedupes";
    rev = "712104864b4f93c16b8dc84d9ed1f9d637d8a41b";
    fetchSubmodules = false;
    sha256 = "sha256-BQUxbUZlaUMjFW4ihaBiPUqi5Pmvf/P30F2gbKgJMEM=";
  };

  vendorHash = null;

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "findimagedupes";
    homepage = "https://github.com/swenson/findimagedupes";
    license = licenses.gpl3;
    platforms = platforms.all;
    inherit version;
  };
}
