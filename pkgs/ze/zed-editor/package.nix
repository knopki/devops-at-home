{ nixpkgs-25-05, ... }:
nixpkgs-25-05.zed-editor.fhsWithPackages (
  ps: with ps; [
    bash-language-server
    docker-compose-language-service
    dockerfile-language-server-nodejs
    eslint
    openssl
    pyright
    ruff
    tailwindcss-language-server
    taplo
    terraform-ls
    vtsls
    yaml-language-server
  ]
)
