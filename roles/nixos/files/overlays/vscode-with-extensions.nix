self: super:
with super.vscode-utils; {
  vscode-with-extensions = super.vscode-with-extensions.override {
    # When the extension is already available in the default extensions set.
    vscodeExtensions = with super.vscode-extensions; [
      bbenoist.Nix
    ]
    # Concise version from the vscode market place when not available in the default set.
    ++ super.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-ansible";
        publisher = "vscoss";
        version = "0.5.2";
        sha256 = "0r1aqfc969354j8b1k9xsg682fynbk4xjp196f3yknlwj66jnpwx";
      }
      {
        name = "bracket-pair-colorizer";
        publisher = "CoenraadS";
        version = "1.0.61";
        sha256 = "0r3bfp8kvhf9zpbiil7acx7zain26grk133f0r0syxqgml12i652";
      }
      {
        name = "gitlens";
        publisher = "eamodio";
        version = "9.5.1";
        sha256 = "10s2g98wv8i0w6fr0pr5xyi8zmh229zn30jn1gg3m5szpaqi1v92";
      }
      {
        name = "indent-rainbow";
        publisher = "oderwat";
        version = "7.2.4";
        sha256 = "02b71r4jfzppm8i65yghw37kmk67ymrm1sdlkv13lj24k297d3v6";
      }
      {
        name = "vscode-kubernetes-tools";
        publisher = "ms-kubernetes-tools";
        version = "0.1.16";
        sha256 = "0hdlxh36gllzm9k83lkad5c2bwlfwhnzv5q98hwgpx2bj6s9cara";
      }
      {
        name = "vscode-todo-highlight";
        publisher = "wayou";
        version = "1.0.4";
        sha256 = "0s925rb668spv602x6g7sld2cs5ayiq7273963v9prvgsr0drlrr";
      }
      {
        name = "unique-lines";
        publisher = "bibhasdn";
        version = "1.0.0";
        sha256 = "1x0lkdvc0247bms200nn2z5m7qaq9lg96ppbgk6lg3mgmxknjijv";
      }
      {
        name = "vscode-icons";
        publisher = "robertohuertasm";
        version = "8.2.0";
        sha256 = "0zfcqs8iy8gsc9b7hkq1xbk7xc5w4g25w3jc5kn2nf9j99g7sh35";
      }
      {
        name = "vscode-yaml";
        publisher = "redhat";
        version = "0.3.0";
        sha256 = "13f094s3qgm3lby7q026gjnamm5bpwj3aqsnwa8qv3y22a7a784j";
      }
      {
        name = "vscode-eslint";
        publisher = "dbaeumer";
        version = "1.8.0";
        sha256 = "0mk1ijbrkj0h3g5pm95arh3aka4jz47zzr8m81055h8q6xsj0rzm";
      }
      {
        name = "prettier-vscode";
        publisher = "esbenp";
        version = "1.8.1";
        sha256 = "0qcm2784n9qc4p77my1kwqrswpji7bp895ay17yzs5g84cj010ln";
      }
      {
        name = "viml";
        publisher = "dunstontc";
        version = "0.1.7";
        sha256 = "0r2dpd07lj8icpbl1nvgk08y6s73bzwv6njpj7m4fcapwjjvhb7l";
      }
      {
        name = "flow-for-vscode";
        publisher = "flowtype";
        version = "1.0.1";
        sha256 = "0b3rldawl64divbf6rpk7crxxf6gpfiai84svafyif2726ibyjd2";
      }
      {
        name = "shell-format";
        publisher = "foxundermoon";
        version = "4.0.4";
        sha256 = "0s4jw2ybwp8aj8sgv7xk0qqy7w3cpbgqz8v9r6vpwalmm6g3319s";
      }
      {
        name = "vscode-styled-components";
        publisher = "jpoissonnier";
        version = "0.0.25";
        sha256 = "12qgx56g79snkf9r7sgmx3lv0gnzp7avf3a5910i0xq9shfr67n0";
      }
      {
        name = "python";
        publisher = "ms-python";
        version = "2019.1.0";
        sha256 = "1jp9i0qxdbrw3jk4in9za9cmfyrd6ii1ilgyg2van3mkq6xpp92w";
      }
      {
        name = "Go";
        publisher = "ms-vscode";
        version = "0.9.2";
        sha256 = "0yxnsby8zz1dvnx8nqrhi4xx316mpjf2hs2c5r6fkzh8zhjccwqz";
      }
      {
        name = "jinjahtml";
        publisher = "samuelcolvin";
        version = "0.8.0";
        sha256 = "0mhiag5jz2np0w9vlj6vgd7vpj0x39m1cyr2lbcwib8mzk2d3zlp";
      }
      {
        name = "rust";
        publisher = "rust-lang";
        version = "0.5.3";
        sha256 = "0nkf6cg1hmmsrvryjs5r0pdwsilfmrmy44wz47jjygyy62ixcad9";
      }
      {
        name = "EditorConfig";
        publisher = "EditorConfig";
        version = "0.13.0";
        sha256 = "1dy7rf9w1mvk65fmxbvhbi5pf6cw2lwi07yhafq9x20c36g6dwyz";
      }
    ];
  };
}
