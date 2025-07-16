{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.lists) optional optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit (lib.strings) getName getVersion makeBinPath;
  cfg = config.programs.helix;
  extraPackagesFinal =
    with pkgs;
    cfg.extraPackages
    # awk
    ++ (optional cfg.extraPackagesAwk awk-language-server)
    # bash
    ++ (optional cfg.extraPackagesBash bash-language-server)
    # css
    ++ (optional cfg.extraPackagesCss vscode-langservers-extracted)
    # docker
    ++ (optionals cfg.extraPackagesDocker [
      docker-compose-language-service
      dockerfile-language-server-nodejs
    ])
    # html
    ++ (optional cfg.extraPackagesHtml vscode-langservers-extracted)
    # jq
    ++ (optional cfg.extraPackagesJq jq-lsp)
    # json
    ++ (optional cfg.extraPackagesJson vscode-langservers-extracted)
    # lua
    ++ (optional cfg.extraPackagesLua lua-language-server)
    # markdown
    ++ (optional cfg.extraPackagesMarkdown marksman)
    # nix
    ++ (optional cfg.extraPackagesNix nil)
    # protobuf
    ++ (optional cfg.extraPackagesProtobuf buf)
    # python
    ++ (optional cfg.extraPackagesPython ruff)
    # svelte
    ++ (optional cfg.extraPackagesSvelte svelte-language-server)
    # terraform
    ++ (optional cfg.extraPackagesTerraform terraform-ls)
    # toml
    ++ (optional cfg.extraPackagesToml taplo)
    # typescript
    ++ (optional cfg.extraPackagesTypescript typescript-language-server)
    # yaml
    ++ (optional cfg.extraPackagesYaml yaml-language-server)

  ;
in
{
  options.programs.helix = {
    enable = mkEnableOption "helix text editor";

    package = mkPackageOption pkgs "helix" { example = "pkgs.evil-helix"; };

    defaultEditor = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to configure {command}`hx` as the default
        editor using the {env}`EDITOR` environment variable.
      '';
    };

    viAlias = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Symlink {command}`vi` to {command}`hx` binary.
      '';
    };

    vimAlias = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Symlink {command}`vim` to {command}`hx` binary.
      '';
    };

    extraPackages = mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.marksman ]";
      description = "Extra packages available to hx.";
    };

    extraPackagesAwk = mkEnableOption "extra packages for awk support";
    extraPackagesBash = mkEnableOption "extra packages for bash support";
    extraPackagesCss = mkEnableOption "extra packages for css support";
    extraPackagesDocker = mkEnableOption "extra packages for docker support";
    extraPackagesHtml = mkEnableOption "extra packages for html support";
    extraPackagesJq = mkEnableOption "extra packages for jq support";
    extraPackagesJson = mkEnableOption "extra packages for json support";
    extraPackagesLua = mkEnableOption "extra packages for lua support";
    extraPackagesMarkdown = mkEnableOption "extra packages for markdown support";
    extraPackagesNix = mkEnableOption "extra packages for nix support";
    extraPackagesProtobuf = mkEnableOption "extra packages for protobuf support";
    extraPackagesPython = mkEnableOption "extra packages for python support";
    extraPackagesSvelte = mkEnableOption "extra packages for svelte support";
    extraPackagesTerraform = mkEnableOption "extra packages for terraform support";
    extraPackagesToml = mkEnableOption "extra packages for toml support";
    extraPackagesTypescript = mkEnableOption "extra packages for typescript support";
    extraPackagesYaml = mkEnableOption "extra packages for yaml support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      if extraPackagesFinal != [ ] then
        [
          (pkgs.symlinkJoin {
            name = "${getName cfg.package}-wrapped-${getVersion cfg.package}";
            paths = [ cfg.package ];
            preferLocalBuild = true;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/hx \
                --suffix PATH : ${makeBinPath extraPackagesFinal}
            '';
          })
        ]
      else
        [ cfg.package ];

    environment.variables = mkIf cfg.defaultEditor { EDITOR = "hx"; };

    environment.shellAliases = {
      vi = mkIf cfg.viAlias "hx";
      vim = mkIf cfg.vimAlias "hx";
    };
  };
}
