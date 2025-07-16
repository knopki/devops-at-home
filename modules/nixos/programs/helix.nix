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
    # bash
    ++ (optionals cfg.extraPackagesBash [
      awk-language-server
      bash-language-server
      shfmt
    ])
    # css
    ++ (optionals cfg.extraPackagesCss [
      dprint
      dprint-plugins.g-plane-malva
      tailwindcss-language-server
      vscode-langservers-extracted
    ])
    # docker
    ++ (optionals cfg.extraPackagesDocker [
      docker-compose-language-service
      dockerfile-language-server-nodejs
      dprint
      dprint-plugins.dprint-plugin-dockerfile
      dprint-plugins.g-plane-pretty_yaml
    ])
    # fish
    ++ (optionals cfg.extraPackagesFish [
      fish
      fish-lsp
    ])
    # html
    ++ (optionals cfg.extraPackagesHtml [
      dprint
      dprint-plugins.g-plane-markup_fmt
      tailwindcss-language-server
      vscode-langservers-extracted
    ])
    # jq
    ++ (optional cfg.extraPackagesJq jq-lsp)
    # json
    ++ (optionals cfg.extraPackagesJson [
      dprint
      dprint-plugins.dprint-plugin-json
      vscode-langservers-extracted
    ])
    # just
    ++ (optionals cfg.extraPackagesJust [
      just
      just-lsp
    ])
    # lua
    ++ (optionals cfg.extraPackagesLua [
      lua-language-server
      stylua
    ])
    # markdown
    ++ (optionals cfg.extraPackagesMarkdown [
      dprint
      dprint-plugins.dprint-plugin-markdown
      marksman
    ])
    # nix
    ++ (optional cfg.extraPackagesNix nil)
    # protobuf
    ++ (optional cfg.extraPackagesProtobuf buf)
    # python
    ++ (optionals cfg.extraPackagesPython [
      pyright
      ruff
      ty
    ])
    # svelte
    ++ (optionals cfg.extraPackagesSvelte [
      dprint
      dprint-plugins.g-plane-markup_fmt
      svelte-language-server
      tailwindcss-language-server
    ])
    # systemd
    ++ (optional cfg.extraPackagesSystemd systemd-language-server)
    # terraform
    ++ (optionals cfg.extraPackagesTerraform [
      terraform
      terraform-ls
    ])
    # toml
    ++ (optional cfg.extraPackagesToml taplo)
    # typescript
    ++ (optionals cfg.extraPackagesTypescript [
      dprint
      dprint-plugins.dprint-plugin-typescript
      tailwindcss-language-server
      typescript-language-server
    ])
    # yaml
    ++ (optionals cfg.extraPackagesYaml [
      dprint
      dprint-plugins.g-plane-pretty_yaml
      yaml-language-server
    ]);
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

    extraPackagesBash = mkEnableOption "extra packages for bash support";
    extraPackagesCss = mkEnableOption "extra packages for css support";
    extraPackagesDocker = mkEnableOption "extra packages for docker support";
    extraPackagesFish = mkEnableOption "extra packages for fish support";
    extraPackagesHtml = mkEnableOption "extra packages for html support";
    extraPackagesJq = mkEnableOption "extra packages for jq support";
    extraPackagesJson = mkEnableOption "extra packages for json support";
    extraPackagesJust = mkEnableOption "extra packages for just support";
    extraPackagesLua = mkEnableOption "extra packages for lua support";
    extraPackagesMarkdown = mkEnableOption "extra packages for markdown support";
    extraPackagesNix = mkEnableOption "extra packages for nix support";
    extraPackagesProtobuf = mkEnableOption "extra packages for protobuf support";
    extraPackagesPython = mkEnableOption "extra packages for python support";
    extraPackagesSvelte = mkEnableOption "extra packages for svelte support";
    extraPackagesSystemd = mkEnableOption "extra packages for systemd support";
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
