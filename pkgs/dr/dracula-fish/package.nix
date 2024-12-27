{
  lib,
  fishPlugins,
  fetchFromGitHub,
  unstableGitUpdater,
}:
fishPlugins.buildFishPlugin {
  pname = "dracula-fish";
  version = "0-unstable-2023-06-23";
  src = fetchFromGitHub {
    owner = "dracula";
    repo = "fish";
    rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
    fetchSubmodules = false;
    sha256 = "sha256-Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Dracula Fish theme";
    homepage = "https://github.com/dracula/fish";
    license = licenses.mit;
    platforms = platforms.all;
    inherit version;
  };
}
