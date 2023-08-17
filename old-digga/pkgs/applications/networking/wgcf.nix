{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "wgcf";
  version = "2.2.11";

  src = fetchurl {
    url = "https://github.com/ViRb3/wgcf/releases/download/v${version}/wgcf_${version}_linux_amd64";
    sha256 = "sha256-HpSFxsHgZtRNbB2F2R0yfJ9KOCPD0jFL1naLPjkxA9A=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/wgcf
    chmod +x $out/bin/wgcf
  '';

  meta = with lib; {
    description = "Cross-platform, unofficial CLI for Cloudflare Warp";
    homepage = "https://github.com/ViRb3/wgcf";
    changelog = "https://github.com/ViRb3/wgcf/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [];
    platforms = ["x86_64-linux"];
  };
}
