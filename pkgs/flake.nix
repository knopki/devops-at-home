{
  description = "Package Sources";

  inputs = {
    # desktops/plasma
    krohnkite.url = "github:esjeon/krohnkite/v0.8";
    krohnkite.flake = false;

    # fish plugins
    fish-kubectl-completions.url = "github:evanlucas/fish-kubectl-completions";
    fish-kubectl-completions.flake = false;

    # steam
    steamcompmgr.url = "github:gamer-os/steamos-compositor-plus";
    steamcompmgr.flake = false;

    # themes
    base16-default-schemes.flake = false;
    base16-default-schemes.url = "github:chriskempson/base16-default-schemes";
    base16-dracula-scheme.flake = false;
    base16-dracula-scheme.url = "github:dracula/base16-dracula-scheme";
    base16-shell.url = "github:chriskempson/base16-shell";
    base16-shell.flake = false;
    base16-textmate.url = "github:chriskempson/base16-textmate";
    base16-textmate.flake = false;
    base16-tmux.url = "github:mattdavis90/base16-tmux";
    base16-tmux.flake = false;
    base16-vim.url = "github:chriskempson/base16-vim";
    base16-vim.flake = false;
    base16-waybar.url = "github:mnussbaum/base16-waybar";
    base16-waybar.flake = false;
    dracula-alacritty.url = "github:dracula/alacritty";
    dracula-alacritty.flake = false;
    dracula-fish.url = "github:dracula/fish";
    dracula-fish.flake = false;
    dracula-wofi.url = "github:dracula/wofi";
    dracula-wofi.flake = false;
    dracula-zathura.url = "github:dracula/zathura";
    dracula-zathura.flake = false;
    ls-colors.url = "github:trapd00r/LS_COLORS";
    ls-colors.flake = false;
  };

  outputs = { self, nixpkgs, ... }: {
    overlay = final: prev: {
      inherit (self) srcs;
    };

    srcs =
      let
        inherit (nixpkgs) lib;

        mkVersion = name: input:
          let
            inputs = (builtins.fromJSON
              (builtins.readFile ./flake.lock)).nodes;

            ref =
              if lib.hasAttrByPath [ name "original" "ref" ] inputs
              then inputs.${name}.original.ref
              else "";

            version =
              let version' = builtins.match
                "[[:alpha:]]*[-._]?([0-9]+(\.[0-9]+)*)+"
                ref;
              in
              if lib.isList version'
              then lib.head version'
              else if input ? lastModifiedDate && input ? shortRev
              then "${lib.substring 0 8 input.lastModifiedDate}_${input.shortRev}"
              else null;
          in
          version;
      in
      lib.mapAttrs
        (pname: input:
          let
            version = mkVersion pname input;
          in
          input // { inherit pname; }
          // lib.optionalAttrs (! isNull version)
            {
              inherit version;
            }
        )
        (lib.filterAttrs (n: _: n != "nixpkgs")
          self.inputs);
  };
}
