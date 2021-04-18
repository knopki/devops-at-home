{ pkgs, nixosConfig, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  programs.git = {
    enable = true;

    aliases = {
      a = "add -p";
      co = "checkout";
      cob = "checkout -b";
      f = "fetch -p";
      c = "commit";
      p = "push";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      r = "restore";
      rs = "restore --staged";
      st = "status -sb";

      # # reset
      undo = "reset --soft HEAD^";
      soft = "reset --soft";
      hard = "reset --hard";
      s1ft = "soft HEAD~1";
      h1rd = "hard HEAD~1";

      # logging
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      plog =
        "log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'";
      tlog =
        "log --stat --since='1 Day Ago' --graph --pretty=oneline --abbrev-commit --date=relative";
      rank = "shortlog -sn --no-merges";

      # delete merged branches
      bdm = "!git branch --merged | grep -v '*' | xargs -n 1 git branch -d";
    };

    extraConfig = {
      core = {
        whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
        quotepath = "off";
      };
      log = {
        decorate = "short";
        abbrevCommit = "true";
      };
      pull.rebase = true;
      push = {
        default = "current";
        followTags = "true";
      };
      apply.whitespace = "fix";
      color.ui = "auto";
      "color \"branch\"" = {
        current = "yellow reverse";
        local = "yellow";
        remote = "green";
      };
      "color \"diff\"" = {
        meta = "yellow bold";
        frag = "magenta bold";
        old = "red";
        new = "green";
      };
      "color \"status\"" = {
        added = "yellow";
        changed = "green";
        untracked = "cyan";
      };
      diff = { renames = "copies"; };
      "diff \"bin\"" = { textconv = "hexdump -v -C"; };
      "diff \"odf\"" = {
        binary = "true";
        textconv = "odt2txt";
      };
      help = { autocorrect = "1"; };
      merge = {
        log = "true";
        ff = "only";
        conflictstyle = "diff3";
      };
      rebase = { autosquash = "true"; };
      include = { path = "local"; };
      status = { showUntrackedFiles = "all"; };
      transfer = { fsckobjects = "true"; };
      init = { defaultBranch = "master"; };
    };

    ignores = [
      "._*"
      ".direnv"
      ".DS_Store"
      ".vscode"
      "*.pyc"
      "Desktop.ini"
      "Thumbs.db"
    ];

    lfs = {
      enable = true;
      skipSmudge = true;
    };

    delta.enable = mkIf nixosConfig.meta.suites.workstation true;
  };
}
