# Mostly stolen from https://github.com/vlaci/blox
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.local.users;
  user = name:
  attrs@{ setupUser ? false, ... }:
    attrs // {
      inherit setupUser;
    };
in
{
  imports = [ ./default-home.nix ./root.nix ./sk.nix ];

  options.local.home-manager.config = mkOption {
    description = ''
      Global Home Manager configuration.
      It can be specified the same way as in `home-manager.users.<name>`
      and it applies to all regular users with enabled `setupUser` attribute.
      There are some optional argument available to the global home manager
      modules, namely:
      - *user*: The current user who the configuration is generated for\
      - *nixosConfig*: The global nixos configuration\
    '';
    type = mkOptionType {
      name = "attribute set or function";
      merge = const (map (x: x.value));
      check = x: isAttrs x || isFunction x;
    };
    default = {};
    example = ''
      {
        local.home-manager.config =
          { pkgs, ... }:
          {
            home.packages = with pkgs; [ rustup ];
          };
      }
    '';
  };

  options.local.users = {
    defaultGroups = mkOption {
      description = "Groups added by profiles";
      internal = true;
      visible = false;
      type = with types; listOf str;
      default = [];
    };

    setupUsers = mkOption {
      description = "Users to setup";
      type = with types; listOf str;
      default = [];
    };

    users = mkOption {
      description = "Users with sane defaults";
      type = with types; loaOf attrs;
      apply = mapAttrs user;
      default = {};
    };
  };

  options.users.users = mkOption {
    type = with types;
      loaOf (
        submodule (
          { name, config, ... }: {
            options = {
              setupUser = mkEnableOption "Setup user";
              extraGroups = mkOption {
                apply = groups:
                  if (config.setupUser && config.uid != 0) then
                    cfg.defaultGroups ++ groups
                  else
                    groups;
              };
              isAdmin = mkEnableOption "sudo access";
              home-config = mkOption {
                description =
                  "Extra home manager configuration to be defined inline";
                type = types.attrs;
                default = {};
              };
            };
            config = { extraGroups = if config.isAdmin then [ "wheel" ] else []; };
          }
        )
      );
  };

  config = let
    nixosConfig = config;
    makeHM = name: _user:
      let
        user = config.users.users.${name};
      in
        (
          { config, options, pkgs, ... }:
            recursiveUpdate {
              _module.args = {
                inherit nixosConfig user;
                username = name;
              };

              imports = nixosConfig.local.home-manager.config ++ [ ./home ];
            } user.home-config
        );
    hmUsers = filterAttrs (name: { setupUser, ... }: setupUser)
      config.local.users.users;
  in
    {
      home-manager.useUserPackages = mkDefault true;
      home-manager.users = mapAttrs makeHM hmUsers;
      local.users.defaultGroups =
        [ "audio" "input" "pulse" "sound" "users" "video" ];
      users = {
        mutableUsers = mkDefault false;
        users = cfg.users;
      };
    };
}
