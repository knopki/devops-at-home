{
  lib,
  pkgs,
  fetchgit,
  unstableGitUpdater,
  python3Packages,
}:
let
  inherit (python3Packages) python;
  wrapperPath = [
    pkgs.nodejs-slim
    pkgs.uv
    pkgs.ripgrep
    pkgs.fd
    pkgs.ffmpeg
    pkgs.libopus
    pkgs.ocrmypdf
    pkgs.opencv
    pkgs.portaudio
    pkgs.tirith
  ]
  ++ lib.optional (pkgs ? agent-browser) pkgs.agent-browser
  ++ lib.optional (pkgs ? mcporter) pkgs.mcporter;
in
python3Packages.buildPythonApplication {
  pname = "hermes-agent";
  version = "2026.3.17-unstable-2026-03-17";
  pyproject = true;

  src = fetchgit {
    url = "https://github.com/NousResearch/hermes-agent.git";
    rev = "ba728f3e63928088495bd79e3641e055e233be8d";
    fetchSubmodules = true;
    hash = "sha256-iKuPFy/pvBEWmzWzSUtQ/MBr0vDp3RTJqrpwvEhwsZI=";
  };

  patches = [
    ./nix-install.patch
  ];

  nativeBuildInputs = with python3Packages; [
    pkgs.perl
    setuptools
    wheel
  ];

  postPatch = ''
    if grep -Fq 'LOGS_DIR = TINKER_ATROPOS_ROOT / "logs"' tools/rl_training_tool.py; then
      substituteInPlace tools/rl_training_tool.py \
        --replace-fail \
          'LOGS_DIR = TINKER_ATROPOS_ROOT / "logs"' \
          $'LOGS_DIR = (\n    Path(os.getenv("TMPDIR", "/tmp")) / "hermes-agent" / "tinker-atropos" / "logs"\n)'
    elif grep -Fq 'LOGS_DIR = Path(os.getenv("HERMES_HOME", Path.home() / ".hermes")) / "logs" / "rl_training"' tools/rl_training_tool.py; then
      substituteInPlace tools/rl_training_tool.py \
        --replace-fail \
          'LOGS_DIR = Path(os.getenv("HERMES_HOME", Path.home() / ".hermes")) / "logs" / "rl_training"' \
          $'LOGS_DIR = (\n    Path(os.getenv("TMPDIR", "/tmp")) / "hermes-agent" / "tinker-atropos" / "logs"\n)'
    fi

    if grep -Fq 'def _ensure_logs_dir():' tools/rl_training_tool.py; then
      perl -0pi -e 's/def _ensure_logs_dir\(\):\n\s+"""Lazily create logs directory on first use \(avoid side effects at import time\)\."""\n\s+if TINKER_ATROPOS_ROOT\.exists\(\):\n\s+LOGS_DIR\.mkdir\(exist_ok=True\)/def _ensure_logs_dir():\n    """Create the logs directory on demand."""\n    LOGS_DIR.mkdir(parents=True, exist_ok=True)/' tools/rl_training_tool.py
    elif grep -Fq '# Ensure logs directory exists' tools/rl_training_tool.py; then
      substituteInPlace tools/rl_training_tool.py \
        --replace-fail \
          'LOGS_DIR.mkdir(exist_ok=True)' \
          'LOGS_DIR.mkdir(parents=True, exist_ok=True)'
    fi
  '';

  propagatedBuildInputs = [
    python3Packages.aiohttp
    python3Packages.anthropic
    python3Packages.croniter
    python3Packages.cryptography
    python3Packages.discordpy
    python3Packages."edge-tts"
    python3Packages."faster-whisper"
    python3Packages.fire
    python3Packages."firecrawl-py"
    python3Packages.httpx
    python3Packages.jinja2
    python3Packages.litellm
    python3Packages.mcp
    python3Packages.numpy
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
    python3Packages.sounddevice
    python3Packages.tenacity
    python3Packages.textual
    python3Packages.typer
    python3Packages.markitdown
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pillow
    python3Packages.ddgs
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

  # NOTE: optional extras that are still outside the current derivation:
  # - fal-client (intentionally skipped for now; not available in current nixpkgs)
  # - honcho-ai
  # - elevenlabs

  pythonImportsCheck = [
    "hermes_cli.main"
  ];

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = with lib; {
    description = "Self-improving AI agent by Nous Research";
    homepage = "https://github.com/NousResearch/hermes-agent";
    license = licenses.mit;
    mainProgram = "hermes";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
