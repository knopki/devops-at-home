{
  lib,
  pkgs,
  fetchgit,
  python3Packages,
}:
let
  inherit (python3Packages) python;
  wrapperPath = [
    pkgs.nodejs
    pkgs.ripgrep
    pkgs.fd
    pkgs.ffmpeg
  ]
  ++ lib.optional (pkgs ? agent-browser) pkgs.agent-browser;
in
python3Packages.buildPythonApplication {
  pname = "hermes-agent";
  version = "0-unstable-2026-03-12";
  pyproject = true;

  src = fetchgit {
    url = "https://github.com/NousResearch/hermes-agent.git";
    rev = "2a62514d1750eb7170a5e5ef1cc9e4fde1fafe78";
    fetchSubmodules = true;
    hash = "sha256-HGhusTP9iOfN8X6gMTU2Ld44SmU74eRTkjLWMoiwI4A=";
  };

  patches = [
    ./nix-install.patch
  ];

  nativeBuildInputs = with python3Packages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    python3Packages.aiohttp
    python3Packages.croniter
    python3Packages.cryptography
    python3Packages.discordpy
    python3Packages."edge-tts"
    python3Packages.fire
    python3Packages."firecrawl-py"
    python3Packages.httpx
    python3Packages.jinja2
    python3Packages.litellm
    python3Packages.mcp
    python3Packages.openai
    python3Packages.platformdirs
    python3Packages."prompt-toolkit"
    python3Packages.ptyprocess
    python3Packages.pydantic
    python3Packages.pyjwt
    python3Packages."python-dotenv"
    python3Packages."python-telegram-bot"
    python3Packages.pyyaml
    python3Packages.requests
    python3Packages.rich
    python3Packages."simple-term-menu"
    python3Packages."slack-bolt"
    python3Packages."slack-sdk"
    python3Packages.tenacity
    python3Packages.textual
    python3Packages.typer
  ];

  postInstall = ''
    sitePackages="$out/${python.sitePackages}"

    cp ./*.py "$sitePackages/"
    cp -r agent "$sitePackages/"
    cp -r gateway "$sitePackages/"
    cp -r mini-swe-agent "$sitePackages/"
    cp -r optional-skills "$sitePackages/"
    cp -r scripts "$sitePackages/"
    cp -r skills "$sitePackages/"
    cp -r tools/environments "$sitePackages/tools/"

    ln -s "$sitePackages/mini-swe-agent/src/minisweagent" "$sitePackages/minisweagent"

    install -Dm644 .env.example "$sitePackages/.env.example"
    install -Dm644 cli-config.yaml.example "$sitePackages/cli-config.yaml.example"
    install -Dm644 package.json "$sitePackages/package.json"
  '';

  makeWrapperArgs = [
    "--set-default"
    "HERMES_NIX_PACKAGE"
    "1"
    "--set-default"
    "HERMES_INTERACTIVE"
    "1"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath wrapperPath)
  ];

  # TODO: package optional extras that are still outside the current derivation:
  # - honcho-ai
  # - elevenlabs

  pythonImportsCheck = [
    "hermes_cli.main"
  ];

  passthru.updateScript = [ ./update.sh ];

  meta = with lib; {
    description = "Self-improving AI agent by Nous Research";
    homepage = "https://github.com/NousResearch/hermes-agent";
    license = licenses.mit;
    mainProgram = "hermes";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
