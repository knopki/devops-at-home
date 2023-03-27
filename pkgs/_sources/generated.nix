# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub }:
{
  base16-default-schemes = {
    pname = "base16-default-schemes";
    version = "daf674291964321cd8c92644f9bbdbf3e7c0e8b3";
    src = fetchFromGitHub ({
      owner = "chriskempson";
      repo = "base16-default-schemes";
      rev = "daf674291964321cd8c92644f9bbdbf3e7c0e8b3";
      fetchSubmodules = false;
      sha256 = "sha256-pwJCHPaHhvkkjIxQhMUm9FA5jZJSrMhu+ciA3A/dsME=";
    });
  };
  base16-dracula-scheme = {
    pname = "base16-dracula-scheme";
    version = "9494b73c343dde092edb05db51f1fd238395f10a";
    src = fetchFromGitHub ({
      owner = "dracula";
      repo = "base16-dracula-scheme";
      rev = "9494b73c343dde092edb05db51f1fd238395f10a";
      fetchSubmodules = false;
      sha256 = "sha256-iHe/Y0+yubXseh3gMWb6wZ4rIb1GAlb6iQNVgiEncfI=";
    });
  };
  base16-shell = {
    pname = "base16-shell";
    version = "588691ba71b47e75793ed9edfcfaa058326a6f41";
    src = fetchFromGitHub ({
      owner = "chriskempson";
      repo = "base16-shell";
      rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
      fetchSubmodules = false;
      sha256 = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
    });
  };
  base16-textmate = {
    pname = "base16-textmate";
    version = "0e51ddd568bdbe17189ac2a07eb1c5f55727513e";
    src = fetchFromGitHub ({
      owner = "chriskempson";
      repo = "base16-textmate";
      rev = "0e51ddd568bdbe17189ac2a07eb1c5f55727513e";
      fetchSubmodules = false;
      sha256 = "sha256-reYGXrhhHNSp/1k6YJ2hxj4jnJQCDgy2Nzxse2PviTA=";
    });
  };
  base16-tmux = {
    pname = "base16-tmux";
    version = "30fc84afc723e027d4497a284fcae3cb75097441";
    src = fetchFromGitHub ({
      owner = "mattdavis90";
      repo = "base16-tmux";
      rev = "30fc84afc723e027d4497a284fcae3cb75097441";
      fetchSubmodules = false;
      sha256 = "sha256-JJ/eRqTayuEKrL9MBe943HpKy7yLyd2Dmes58KN1jdk=";
    });
  };
  base16-vim = {
    pname = "base16-vim";
    version = "3be3cd82cd31acfcab9a41bad853d9c68d30478d";
    src = fetchFromGitHub ({
      owner = "chriskempson";
      repo = "base16-vim";
      rev = "3be3cd82cd31acfcab9a41bad853d9c68d30478d";
      fetchSubmodules = false;
      sha256 = "sha256-uJvaYYDMXvoo0fhBZUhN8WBXeJ87SRgof6GEK2efFT0=";
    });
  };
  base16-waybar = {
    pname = "base16-waybar";
    version = "d2f943b1abb9c9f295e4c6760b7bdfc2125171d2";
    src = fetchFromGitHub ({
      owner = "mnussbaum";
      repo = "base16-waybar";
      rev = "d2f943b1abb9c9f295e4c6760b7bdfc2125171d2";
      fetchSubmodules = false;
      sha256 = "sha256-ehb4CLLPJ/SjMz53/inuP9ine2CfIpexp2O1lVHihM0=";
    });
  };
  dracula-alacritty = {
    pname = "dracula-alacritty";
    version = "77aff04b9f2651eac10e5cfa80a3d85ce43e7985";
    src = fetchFromGitHub ({
      owner = "dracula";
      repo = "alacritty";
      rev = "77aff04b9f2651eac10e5cfa80a3d85ce43e7985";
      fetchSubmodules = false;
      sha256 = "sha256-eJkVxcaDiIbTrI1Js5j+Nl88gawTE/mfVjstjqQOOdU=";
    });
  };
  dracula-fish = {
    pname = "dracula-fish";
    version = "610147cc384ff161fbabb9a9ebfd22b743f82b67";
    src = fetchFromGitHub ({
      owner = "dracula";
      repo = "fish";
      rev = "610147cc384ff161fbabb9a9ebfd22b743f82b67";
      fetchSubmodules = false;
      sha256 = "sha256-WywEGAGaRwfHJpT+B3oKoyrnLJZxURTQ+MK9e5Asxl0=";
    });
  };
  dracula-wofi = {
    pname = "dracula-wofi";
    version = "04f905b10796f9491f30be024b0b5ff28c675648";
    src = fetchFromGitHub ({
      owner = "dracula";
      repo = "wofi";
      rev = "04f905b10796f9491f30be024b0b5ff28c675648";
      fetchSubmodules = false;
      sha256 = "sha256-umL6QihHDJly7MjQYme2uyBzUbwl8nviPujYSxrVT+U=";
    });
  };
  dracula-zathura = {
    pname = "dracula-zathura";
    version = "b597b1537aa125e8829bef2cc57a0b0c6a6b35a1";
    src = fetchFromGitHub ({
      owner = "dracula";
      repo = "zathura";
      rev = "b597b1537aa125e8829bef2cc57a0b0c6a6b35a1";
      fetchSubmodules = false;
      sha256 = "sha256-g6vxwPw0Q9QFJBc3d4R3ZsHnnEvU5o1f4DSuyLeN5XQ=";
    });
  };
  ls-colors = {
    pname = "ls-colors";
    version = "e36eebfb3e1b39497c6038cdc70c75109b6434de";
    src = fetchFromGitHub ({
      owner = "trapd00r";
      repo = "LS_COLORS";
      rev = "e36eebfb3e1b39497c6038cdc70c75109b6434de";
      fetchSubmodules = false;
      sha256 = "sha256-KsVuHBd4CzAWDeobS0N4NW+z1KMK1kBnZg14g67SCeQ=";
    });
  };
}
