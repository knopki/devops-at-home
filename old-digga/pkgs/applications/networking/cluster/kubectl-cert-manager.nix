{ lib, stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "kubectl-cert-manager";
  version = "1.5.4";

  src = fetchzip {
    url = "https://github.com/jetstack/cert-manager/releases/download/v${version}/kubectl-cert_manager-linux-amd64.tar.gz";
    stripRoot = false;
    sha256 = "sha256-jdrmMjNXRsPKWIqZzKuitBe5segCJEZhc07D8IeOaag=";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv kubectl-cert_manager $out/bin
  '';

  meta = with lib; {
    description = "kubectl plugin that can help you to manage cert-manager resources inside your cluster";
    homepage = "https://cert-manager.io/docs/usage/kubectl-plugin/";
    changelog = "https://github.com/jetstack/cert-manager/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
