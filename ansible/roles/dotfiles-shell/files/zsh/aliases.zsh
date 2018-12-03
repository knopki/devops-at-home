alias _fzf_complete_gopass='_fzf_complete_pass'
alias fzf='fzf-tmux -m'
alias gmpv='flatpak run --filesystem=xdg-download io.github.GnomeMpv --enqueue'
alias grep='grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias ls='ls --color=auto'
alias man='nocorrect man'
alias mv='nocorrect mv'
alias o=xdg-open
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-synchronize="rsync -avzu --delete --progress -h"
alias rsync-update="rsync -avzu --progress -h"
alias sudo='nocorrect sudo'
alias svim='sudo -E vim'

# git
alias gco="git checkout"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias gst="git status"
alias gundo="git reset --soft HEAD^"

# flatpaks
if (( $+commands[com.github.sharkdp.Bat] )); then
  alias bat="com.github.sharkdp.Bat"
fi
