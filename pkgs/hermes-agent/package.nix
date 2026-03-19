{
  lib,
  pkgs,
  python3,
  fetchgit,
}:
let
  wrapperPath = [
    # find tools (optional)
    pkgs.fd
    pkgs.ripgrep
    # security checks (optional)
    pkgs.tirith
    # uvx + npm for mcp, etc (optional)
    pkgs.uv
    pkgs.nodejs-slim
    # voice mode (optional)
    pkgs.ffmpeg
    pkgs.libopus
    pkgs.portaudio
    # ascii-video skill (optional)
    pkgs.opencv
    # OCR (optional)
    pkgs.ocrmypdf
  ]
  # browser tool (optional)
  ++ lib.optional (pkgs ? agent-browser) pkgs.agent-browser
  # openspec (optional)
  ++ lib.optional (pkgs ? openspec) pkgs.openspec
  # mcporter tool (optional)
  ++ lib.optional (pkgs ? mcporter) pkgs.mcporter
  # rust token killer (optional)
  ++ lib.optional (pkgs ? rtk) pkgs.rtk;
in
python3.pkgs.buildPythonApplication rec {
  pname = "hermes-agent";
  version = "2026.3.17-unstable-2026-03-18";
  pyproject = true;

  src = fetchgit {
    url = "https://github.com/NousResearch/hermes-agent.git";
    rev = "7b6d14e62a2b7f0015a06e48d7ba89164f3caced";
    fetchSubmodules = true;
    hash = "sha256-xhucLx71YLcMZFrXXVK1ZlyluzIJvCJcAkBTzv4j3Yg=";
  };

  patches = [
    ./doctor-agent-browser.patch
    ./web_tools-firecrawl.patch
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies =
    with python3.pkgs;
    [
      # Core
      openai
      anthropic
      python-dotenv
      fire
      httpx
      rich
      tenacity
      pyyaml
      requests
      jinja2
      pydantic
      # Interactive CLI
      prompt-toolkit
      # Tools
      firecrawl-py
      # Text-to-speech
      edge-tts
      faster-whisper
      # mini-swe-agent deps
      litellm
      typer
      platformdirs
      # Skills Hub
      pyjwt
      # messaging
      python-telegram-bot
      discordpy
      aiohttp
      slack-bolt
      slack-sdk
      # cron
      croniter
      # cli
      simple-term-menu
      # voice
      sounddevice
      numpy
      # pty
      ptyprocess
      # mcp
      mcp

      # very optional
      markitdown
      scipy
      pillow
      ddgs
    ]
    ++ lib.optional (pkgs ? fal-client) pkgs.fal-client
    ++ lib.optional (python3.pkgs ? fal-client) python3.pkgs.fal-client
    ++ lib.optional (python3.pkgs ? agent-client-protocol) python3.pkgs.agent-client-protocol;

  pythonRelaxDeps = [
  ];

  pythonRemoveDeps = [
    "parallel-web"
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath wrapperPath)
  ];

  postInstall = ''
    sitePackages="$out/${python3.pkgs.python.sitePackages}"

    cp ./minisweagent_path.py "$sitePackages/"
    cp -r mini-swe-agent "$sitePackages/"
    ln -s "$sitePackages/mini-swe-agent/src/minisweagent" "$sitePackages/minisweagent"
  '';

  pythonImportsCheck = [ "hermes_cli" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ ];
  versionCheckProgramArg = [ "--version" ];

  passthru.category = "AI Assistants";

  meta = with lib; {
    description = "Self-improving AI agent by Nous Research — creates skills from experience and runs anywhere";
    homepage = "https://hermes-agent.nousresearch.com/";
    changelog = "https://github.com/NousResearch/hermes-agent/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "hermes";
  };
}
