{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--color=dark" ];
  };
}
