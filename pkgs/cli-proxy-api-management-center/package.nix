{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "cli-proxy-api-management-center";
  version = "1.17.7";

  src = fetchurl {
    url = "https://github.com/router-for-me/Cli-Proxy-API-Management-Center/releases/download/v${version}/management.html";
    hash = "sha256-rmo9qz3RITlzIGWWmkulkqVWwjw47e+1cjoBk7bVQs4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 "$src" "$out/management.html"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Management panel HTML asset for CLI Proxy API";
    homepage = "https://github.com/router-for-me/Cli-Proxy-API-Management-Center";
    changelog = "https://github.com/router-for-me/Cli-Proxy-API-Management-Center/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
