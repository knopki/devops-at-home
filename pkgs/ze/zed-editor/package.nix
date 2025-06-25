{ nixpkgsUnstable, ... }:
nixpkgsUnstable.zed-editor.fhsWithPackages (
  ps: with ps; [
    bash-language-server
    docker-compose-language-service
    dockerfile-language-server-nodejs
    eslint
    pyright
    ruff
    tailwindcss-language-server
    taplo
    terraform-ls
    vtsls
    yaml-language-server
  ]
)
