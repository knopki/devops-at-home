{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "honcho-ai";
  version = "2.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "honcho_ai";
    hash = "sha256-b97r+UVOYrxSPVeIjlA1nme6r9sh9oYh+cFOCNwAYjo=";
  };

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  dependencies =
    with python3.pkgs;
    [
      httpx
      pydantic
    ]
    ++ lib.optionals (lib.versionOlder python3.pythonVersion "3.12") [
      typing-extensions
    ];

  pythonImportsCheck = [ "honcho" ];

  meta = with lib; {
    description = "Official DX Optimized Python SDK for Honcho";
    homepage = "https://github.com/plastic-labs/honcho";
    license = licenses.asl20;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.all;
  };
}
