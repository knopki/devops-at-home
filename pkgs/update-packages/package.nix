{
  pkgs,
  self,
  ...
}:
let
  inherit (builtins) concatStringsSep;
  inherit (pkgs.lib) escapeShellArg;
  nixShellPath = "${self.inputs.nixpkgs.outPath}/maintainers/scripts/update.nix";
  overlaysList = "[ (import ./. {  }).overlays.my-packages ]";
  predicate = ''
    let
      prefix = "${self.outPath}/pkgs";
      prefixLen = builtins.stringLength prefix;
    in (_: p: (builtins.substring 0 prefixLen (p.meta.position or "")) == prefix)
  '';
  execCmd = concatStringsSep " " [
    "exec nix-shell"
    (escapeShellArg nixShellPath)
    "--argstr keep-going true"
    "--argstr skip-prompt true"
    "--arg include-overlays ${escapeShellArg overlaysList}"
  ];
  allCmd = "${execCmd} --arg predicate ${escapeShellArg predicate}";
in
pkgs.writeShellScriptBin "update-packages" ''
  if [[ "$PRJ_ROOT" != "" ]]; then cd "$PRJ_ROOT"; fi
  if [[ "$1" == "" ]]; then
    echo "Update packages in \$ROOT/pkgs"
    echo ""
    echo "update-packages [--all|<package name>] [--args commit true]"
    echo ""
    echo "    --all|<package name>  Update all or one package"
    echo "    --argstr commit true  Create git commit after update"
    exit 0
  fi

  if [[ "$1" == "--all" ]]; then
      shift
      ${allCmd} $@
  else
      PKG_NAME="$1"
      shift
      ${execCmd} --argstr package "$PKG_NAME" $@
  fi
''
