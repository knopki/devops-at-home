{ pkgs, ... }:
{
  zsh-256color = {
    name = "zsh-256color";
    src = pkgs.fetchFromGitHub {
      owner = "chrissicool";
      repo = "zsh-256color";
      rev = "ae40a49ccfc7520d2d7b575aaea160ff876fe3dc";
      sha256 = "0c2yzbd4y0fyn9yycrxh32am27r0df0x3r526gf1pmyqiv49rg5z";
    };
  };

  # pure dependency
  zsh-async = {
    name = "zsh-async";
    file = "async.plugin.zsh";
    src = pkgs.fetchFromGitHub {
      owner = "mafredri";
      repo = "zsh-async";
      rev = "v1.7.0";
      sha256 = "1jbbypgn0r4pilhv2s2p11vbkkvlnf75wrhxfcvr7bfjpzyp9wbc";
    };
  };

  pure = {
    name = "pure";
    src = pkgs.fetchFromGitHub {
      owner = "sindresorhus";
      repo = "pure";
      rev = "v1.9.0";
      sha256 = "0qimbksjn7w35wqfm40sjhwkx843m1szqmwlmw3xxf69yx1hyz6w";
    };
  };

  zsh-completions = {
    name = "zsh-completions";
    src = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-completions";
      rev = "0.30.0";
      sha256 = "1yf4rz99acdsiy0y1v3bm65xvs2m0sl92ysz0rnnrlbd5amn283l";
    };
  };

  calc = {
    name = "calc";
    src = pkgs.fetchFromGitHub {
      owner = "arzzen";
      repo = "calc.plugin.zsh";
      rev = "6aa46a8d4731645ef135d01c99e2fd32615a8a94";
      sha256 = "0gxidjld92pfzs88byb4vmvkqcbdr53x4rmw8ync0l2z2faijmlp";
    };
  };

  you-should-use = {
    name = "you-should-use";
    src = pkgs.fetchFromGitHub {
      owner = "MichaelAquilina";
      repo = "zsh-you-should-use";
      rev = "1.1.0";
      sha256 = "0fig5ralagi5jajk7gdm52jvwql17qk9cd6j98qsndvckb26a753";
    };
  };

  fast-syntax-highlighting = {
    name = "fast-syntax-highlighting";
    src = pkgs.fetchFromGitHub {
      owner = "zdharma";
      repo = "fast-syntax-highlighting";
      rev = "v1.28";
      sha256 = "106s7k9n7ssmgybh0kvdb8359f3rz60gfvxjxnxb4fg5gf1fs088";
    };
  };

  zsh-history-substring-search = {
    name = "zsh-history-substring-search";
    file = "zsh-history-substring-search.zsh";
    src = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-history-substring-search";
      rev = "v1.0.1";
      sha256 = "0lgmq1xcccnz5cf7vl0r0qj351hwclx9p80cl0qczxry4r2g5qaz";
    };
  };
}
