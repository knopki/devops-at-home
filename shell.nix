{ pkgs ? import <nixpkgs> {}, sops-nix ? import <sops-nix> {} }:
let
  myPython = pkgs.python3.withPackages (ps: with ps; [ pyparsing ]);
in
pkgs.mkShell {
  sopsPGPKeyDirs = [
    "./secrets/keys/hosts"
    "./secrets/keys/users"
  ];

  nativeBuildInputs = with pkgs; [
    (pass.withExtensions (ext: with ext; [ pass-otp ]))
    ansible
    black
    git
    myPython
    nixFlakes
    sops
    sops-nix.ssh-to-pgp
    sops-nix.sops-pgp-hook
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
}
