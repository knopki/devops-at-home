{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      aws.disabled = true;
      conda.disabled = true;
      crystal.disabled = true;
      directory = {
        truncation_length = 2;
        fish_style_pwd_dir_length = 2;
      };
      elixir.disabled = true;
      elm.disabled = true;
      gcloud.disabled = true;
      nim.disabled = true;
      kubernetes.disabled = true;
      purescript.disabled = true;
      zig.disabled = true;
    };
  };
}
