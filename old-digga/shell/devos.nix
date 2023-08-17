{
  pkgs,
  inputs,
  ...
}: let
  hooks = import ./hooks;

  pkgWithCategory = category: package: {inherit package category;};
  linter = pkgWithCategory "linter";
  devos = pkgWithCategory "devos";
in {
  _file = toString ./.;

  imports = ["${inputs.digga.inputs.devshell.outPath}/extra/git/hooks.nix"];
  git = {inherit hooks;};

  devshell.startup = {
    # tempfix: remove when merged https://github.com/numtide/devshell/pull/123
    load_profiles = pkgs.lib.mkForce (pkgs.lib.noDepEntry ''
      # PATH is devshell's exorbitant privilige:
      # fence against its pollution
      _PATH=''${PATH}
      # Load installed profiles
      for file in "$DEVSHELL_DIR/etc/profile.d/"*.sh; do
        # If that folder doesn't exist, bash loves to return the whole glob
        [[ -f "$file" ]] && source "$file"
      done
      # Exert exorbitant privilige and leave no trace
      export PATH=''${_PATH}
      unset _PATH
    '');
    sops.text = ''
      source ${pkgs.sops-import-keys-hook.outPath}/nix-support/setup-hook
      sopsImportKeysHook
    '';
  };

  commands = with pkgs;
    [
      (devos nixUnstable)
      (devos agenix)
      {
        category = "devos";
        name = pkgs.nvfetcher.pname;
        help = pkgs.nvfetcher.meta.description;
        command = "cd $PRJ_ROOT/pkgs; ${pkgs.nvfetcher}/bin/nvfetcher -c ./sources.toml $@";
      }
      (linter nixpkgs-fmt)
      (linter editorconfig-checker)
      (devos pkgs.deploy-rs)
      {
        name = "sops-edit";
        category = "devos";
        command = "${pkgs.sops}/bin/sops $@";
        help = "sops-edit <secretFileName>.yaml | Edit secretFile with sops-nix";
      }
    ]
    ++ lib.optional
    (system != "i686-linux")
    (devos cachix)
    ++ lib.optional
    (system != "aarch64-darwin")
    (devos inputs.nixos-generators.defaultPackage.${pkgs.system});

  env = [
    {
      name = "sopsPGPKeyDirs";
      value = "./secrets/keys/hosts ./secrets/keys/users";
    }
  ];

  packages = with pkgs; [
    sops
    sops-init-gpg-key
    ssh-to-pgp
  ];
}
