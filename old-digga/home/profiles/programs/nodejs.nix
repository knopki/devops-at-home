{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nodejs
    nodePackages.typescript
    nodePackages.prettier
    yarn
  ];

  home.file = {
    ".npmrc".text = ''
      cache="${config.xdg.cacheHome}/npm"
      prefix="${config.xdg.dataHome}/npm"
    '';
  };

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:${config.xdg.dataHome}/npm/bin:\${PATH}";
  };
}
