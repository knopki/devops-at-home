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
  cfg = config.custom.helix;
  extraPackagesFinal =
    with pkgs;
    cfg.extraPackages
    # bash
    ++ (optionals cfg.extraPackagesBash [
      bash-language-server # shellcheck included
      shfmt
    ])
    # css
    ++ (optional cfg.extraPackagesCss biome)
    # docker
    ++ (optionals cfg.extraPackagesDocker [
      docker-compose-language-service
      dockerfile-language-server
      dprint
      dprint-plugins.dprint-plugin-dockerfile
      dprint-plugins.g-plane-pretty_yaml
    ])
    # fish
    ++ (optionals cfg.extraPackagesFish [
      fish
      fish-lsp
    ])
    # git
    ++ (optionals cfg.extraPackagesGit [
      git
      lazygit
    ])
    # html
    ++ (optional cfg.extraPackagesHtml biome)
    # jq
    ++ (optional cfg.extraPackagesJq jq-lsp)
    # json
    ++ (optional cfg.extraPackagesJson biome)
    # just
    ++ (optionals cfg.extraPackagesJust [
      just
      just-lsp
    ])
    # markdown
    ++ (optionals cfg.extraPackagesMarkdown [
      dprint
      dprint-plugins.dprint-plugin-markdown
      marksman
    ])
    # nix
    ++ (optionals cfg.extraPackagesNix [
      nixd
      nixfmt
    ])
    # protobuf
    ++ (optional cfg.extraPackagesProtobuf buf)
    # python
    ++ (optionals cfg.extraPackagesPython [
      ruff
      ty
    ])
    # systemd
    ++ (optional cfg.extraPackagesSystemd systemd-lsp)
    # toml
    ++ (optional cfg.extraPackagesToml tombi)
    # typescript
    ++ (optional cfg.extraPackagesTypescript biome)
    # yaml
    ++ (optionals cfg.extraPackagesYaml [
      dprint
      dprint-plugins.g-plane-pretty_yaml
      yaml-language-server
    ]);
  wrappedHx = pkgs.symlinkJoin {
    name = "${getName cfg.package}-wrapped-${getVersion cfg.package}";
    paths = [ cfg.package ];
    preferLocalBuild = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/hx \
        --suffix PATH : ${makeBinPath extraPackagesFinal}
    '';
  };
in
{
  options.custom.helix = {
    enable = mkEnableOption "helix text editor";

    package = mkPackageOption pkgs "helix" { example = "pkgs.evil-helix"; };

    finalPackage = mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Resulting customized neovim package.";
    };

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

    finalExtraPackages = mkOption {
      type = with lib.types; listOf package;
      readOnly = true;
      description = "Resulting extra packages available to hx.";
    };

    extraPackagesBash = mkEnableOption "extra packages for bash support";
    extraPackagesCss = mkEnableOption "extra packages for css support";
    extraPackagesDocker = mkEnableOption "extra packages for docker support";
    extraPackagesFish = mkEnableOption "extra packages for fish support";
    extraPackagesGit = mkEnableOption "extra packages for git support";
    extraPackagesHtml = mkEnableOption "extra packages for html support";
    extraPackagesJq = mkEnableOption "extra packages for jq support";
    extraPackagesJson = mkEnableOption "extra packages for json support";
    extraPackagesJust = mkEnableOption "extra packages for just support";
    extraPackagesMarkdown = mkEnableOption "extra packages for markdown support";
    extraPackagesNix = mkEnableOption "extra packages for nix support";
    extraPackagesProtobuf = mkEnableOption "extra packages for protobuf support";
    extraPackagesPython = mkEnableOption "extra packages for python support";
    extraPackagesSystemd = mkEnableOption "extra packages for systemd support";
    extraPackagesTerraform = mkEnableOption "extra packages for terraform support";
    extraPackagesToml = mkEnableOption "extra packages for toml support";
    extraPackagesTypescript = mkEnableOption "extra packages for typescript support";
    extraPackagesYaml = mkEnableOption "extra packages for yaml support";
  };

  config = mkIf cfg.enable {
    environment = {
      variables = mkIf cfg.defaultEditor { EDITOR = "hx"; };

      shellAliases = {
        vi = mkIf cfg.viAlias "hx";
        vim = mkIf cfg.vimAlias "hx";
      };

      systemPackages = [ cfg.finalPackage ];
    };

    custom.helix = {
      finalPackage = if extraPackagesFinal != [ ] then wrappedHx else cfg.package;
      finalExtraPackages = extraPackagesFinal;
    };
  };
}
