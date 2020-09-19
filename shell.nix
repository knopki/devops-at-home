{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    ansible
    git
    git-crypt
    nixFlakes
    (pass.withExtensions (ext: with ext; [ pass-otp ]))
  ];

  NIX_CONF_DIR = let
    current = pkgs.lib.optionalString
      (builtins.pathExists /etc/nix/nix.conf)
      (builtins.readFile /etc/nix/nix.conf);

    nixConf = pkgs.writeTextDir
      "opt/nix.conf"
      ''
        ${current}
        experimental-features = nix-command flakes ca-references
      '';
  in
    "${nixConf}/opt";

  shellHook = ''
    mkdir -p secrets
  '';
}
