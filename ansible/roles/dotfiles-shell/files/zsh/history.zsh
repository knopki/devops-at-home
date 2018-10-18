# Create one history file per year per user per machine
# This allows easy sync of history between machines with syncthing/git-annex
_HISTFILE_DIR="${ZDATADIR}/history"
HISTFILE="${_HISTFILE_DIR}/history.$(date +%Y).$(whoami)@$(hostname -s)"
mkdir -p $_HISTFILE_DIR
if [[ ! -e $HISTFILE ]]; then touch $HISTFILE; fi
HISTSIZE=100000000
SAVEHIST=100000000

# Read all history files
_TEMP=$(mktemp)
cat $_HISTFILE_DIR/history.* | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{if (sub(/\\$/,date)) printf "%s", $0; else print $0}' | LC_ALL=C sort -u | awk -v date="WILL_NOT_APPEAR$(date +"%s")" '{gsub('date',"\\\n"); print $0}' >$_TEMP
fc -R $_TEMP
rm $_TEMP

# yyyy-mm-dd
alias history='fc -il 1'

setopt bang_hist # Treat the '!' character specially during expansion.
setopt append_history
setopt extended_history   # Write the history file in the ':start:elapsed;command' format.
setopt hist_expire_dups_first    # Expire a duplicate event first when trimming history.
setopt hist_ignore_dups          # ignore duplication command history list
setopt hist_ignore_all_dups      # Delete an old recorded event if a new event is a duplicate.
setopt hist_find_no_dups  # Do not display a previously found event.
setopt hist_ignore_space  # Do not record an event starting with a space.
setopt hist_save_no_dups         # Do not write a duplicate event to the history file.
setopt hist_verify        # Do not execute immediately upon history expansion.
setopt inc_append_history # Write to the history file immediately, not when the shell exits.
setopt share_history      # share command history data
setopt hist_beep          # Beep when accessing non-existent history.
