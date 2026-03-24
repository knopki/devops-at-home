{
  lib,
  pkgs,
  python3,
  fetchgit,
}:
let
  wrapperPath = [
    # security checks (optional)
    pkgs.tirith
    # uvx + npm (optional)
    pkgs.uv
    pkgs.nodejs-slim
    # voice mode (optional)
    pkgs.ffmpeg
    pkgs.libopus
    pkgs.portaudio
    pkgs.espeak
    # clipboard
    pkgs.wl-clipboard
  ]
  # browser tool (optional)
  ++ lib.optional (pkgs ? agent-browser) pkgs.agent-browser
  # rust token killer (optional)
  ++ lib.optional (pkgs ? rtk) pkgs.rtk;
in
python3.pkgs.buildPythonApplication rec {
  pname = "hermes-agent";
  version = "2026.3.23-unstable-2026-03-24";
  pyproject = true;

  src = fetchgit {
    url = "https://github.com/NousResearch/hermes-agent.git";
    rev = "87e2626cf6d490f03f48bf44d6d8c324bed56153";
    fetchSubmodules = true;
    hash = "sha256-itTx8uwLypAvb/P8sPJApIm0N04vD39RR308ka2esx4=";
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
    ++ lib.optional (pkgs ? honcho-ai) pkgs.honcho-ai
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
