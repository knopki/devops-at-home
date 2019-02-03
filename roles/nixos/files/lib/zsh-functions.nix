{
  cdf = ''
    # cdf - cd into the directory of the selected file
    local file
    local dir
    file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
  '';

  fcd = ''
    # fd - cd to selected directory
    local dir
    dir=$(find ''${1:-.} -path '*/\.*' -prune \
                    -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
  '';

  fda = ''
    # fda - cd to selected directory including hidden directories
    local dir
    dir=$(find ''${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
  '';

  fdr = ''
    # fdr - cd to selected parent directory
    local declare dirs=()
    get_parent_dirs() {
      if [[ -d "''${1}" ]]; then dirs+=("$1"); else return; fi
      if [[ "''${1}" == '/' ]]; then
        for _dir in "''${dirs[@]}"; do echo $_dir; done
      else
        get_parent_dirs $(dirname "$1")
      fi
    }
    local DIR=$(get_parent_dirs $(realpath "''${1:-$(pwd)}") | fzf-tmux --tac)
    cd "$DIR"
  '';

  fe = ''
    # fe [FUZZY PATTERN] - Open the selected file with the default editor
    #   - Bypass fuzzy finder if there's only one match (--select-1)
    #   - Exit if there's no match (--exit-0)
    IFS='
    '
    local declare files=($(fzf-tmux --query="$1" --select-1 --exit-0))
    [[ -n "$files" ]] && ''${EDITOR:-vim} "''${files[@]}"
    unset IFS
  '';

  fgshow = ''
    # fgshow - git commit browser
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                  (grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                  {}
    FZF-EOF"
  '';

  fgstash = ''
    # fgstash - easier way to deal with stashes
    # type fgstash to get a list of your stashes
    # enter shows you the contents of the stash
    # ctrl-d shows a diff of the stash against your current HEAD
    # ctrl-b checks the stash out as a branch, for easier merging
    local out q k sha
    while out=$(
      git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf --ansi --no-sort --query="$q" --print-query \
          --expect=ctrl-d,ctrl-b);
    do
      mapfile -t out <<< "$out"
      q="''${out[0]}"
      k="''${out[1]}"
      sha="''${out[-1]}"
      sha="''${sha%% *}"
      [[ -z "$sha" ]] && continue
      if [[ "$k" == 'ctrl-d' ]]; then
        git diff $sha
      elif [[ "$k" == 'ctrl-b' ]]; then
        git stash branch "stash-$sha" $sha
        break;
      else
        git stash show -p $sha
      fi
    done
  '';

  fh = ''
    # fh - repeat history
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
  '';

  fkill = ''
    # fkill - kill process
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "x$pid" != "x" ]
    then
      kill -''${1:-9} $pid
    fi
  '';

  fo = ''
    # Modified version of fe where you can press
    #   - CTRL-O to open with `open` command,
    #   - CTRL-E or Enter key to open with the $EDITOR
    local out file key
    out=$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
    key=$(head -1 <<< "$out")
    file=$(head -2 <<< "$out" | tail -1)
    if [ -n "$file" ]; then
      [ "$key" = ctrl-o ] && xdg-open "$file" || ''${EDITOR:-vim} "$file"
    fi
  '';

  gb = ''
    is_in_git_repo || return
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --border --ansi --multi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
  '';

  gf = ''
    is_in_git_repo || return
    git -c color.status=always status --short |
    fzf --border -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
    cut -c4- | sed 's/.* -> //'
  '';

  gh = ''
    is_in_git_repo || return
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf --border --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'Press CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
    grep -o "[a-f0-9]\{7,\}"
  '';

  gr = ''
    is_in_git_repo || return
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf --border --tac \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
    cut -d$'\t' -f1
  '';

  gt = ''
    is_in_git_repo || return
    git tag --sort -version:refname |
    fzf --border --multi --preview-window right:70% \
      --preview 'git show --color=always {} | head -'$LINES
  '';

  is_in_git_repo = ''
    git rev-parse HEAD > /dev/null 2>&1
  '';

  save_pwd = ''
    if [[ $TERM == xterm-termite ]] && [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
      echo $PWD > "/tmp/''${USER}-pwd"
    fi
  '';

  source_if_possible = ''
    if [[ -r $1 ]]; then
      source $1
    fi
  '';
}
