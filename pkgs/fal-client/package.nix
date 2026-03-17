{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "fal-client";
  version = "0.13.1";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "fal_client";
    hash = "sha256-nhwH0KYbRSqP+0jBmd5fJUPXVG8SMPYxI3BEMSfF6Tc=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    httpx
    httpx-sse
    msgpack
    websockets
  ];

  pythonImportsCheck = [ "fal_client" ];

  meta = with lib; {
    description = "Python client for fal.ai";
    homepage = "https://github.com/fal-ai/fal";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.all;
  };
}
