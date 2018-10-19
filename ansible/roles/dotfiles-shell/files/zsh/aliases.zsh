alias bc='bc -l -q ${XDG_CONFIG_HOME}/bc'
alias grep='grep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias ls='ls --color=auto'
alias man='nocorrect man'
alias mv='nocorrect mv'
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-synchronize="rsync -avzu --delete --progress -h"
alias rsync-update="rsync -avzu --progress -h"
alias sudo='nocorrect sudo'
alias fzf='fzf-tmux -m'
alias _fzf_complete_gopass='_fzf_complete_pass'
