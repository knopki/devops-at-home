{ config, lib, pkgs, ... }:
with lib; {
  options.knopki.git.enable = mkEnableOption "git defaults";

  config = mkIf config.knopki.git.enable {
    programs.git = {
      aliases = {
        co = "checkout";
        hist =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        st = "status";
        undo = "reset --soft HEAD^";
      };
      enable = true;
      extraConfig = {
        core = {
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
          quotepath = "off";
        };
        log = {
          decorate = "short";
          abbrevCommit = "true";
        };
        pull = {
          rebase = "true";
        };
        push = {
          default = "current";
          followTags = "true";
        };
        apply = { whitespace = "fix"; };
        color = { ui = "auto"; };
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
    };
  };
}
