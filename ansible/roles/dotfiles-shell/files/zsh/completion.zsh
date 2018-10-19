unsetopt menu_complete # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu        # show completion menu on succesive tab press
setopt auto_name_dirs   # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt complete_in_word # Allow completion from within a word/phrase
setopt always_to_end    # When completing from the middle of a word, move the cursor to the end of the word

unsetopt correct_all # spelling correction for arguments
setopt correct       # spelling correction for commands

zmodload zsh/terminfo

# Treat these characters as part of a word.
# WORDCHARS=''
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

zmodload -i zsh/complist

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZPLUG_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
	adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
	clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
	gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
	ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
	named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
	operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
	rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
	usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

expand-or-complete-with-dots() {
	# toggle line-wrapping off and back on again
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
	print -Pn "%{%F{red}......%f%}"
	[[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

	zle expand-or-complete
	zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# continious rehash
zstyle ':completion:*' rehash true

# Addons
# zsh-completions
source "${ZPLUGINSDIR}/zsh-completions/zsh-completions.plugin.zsh"

# fzf
source "${ZPLUGINSDIR}/fzf/shell/completion.zsh"

# Google Cloud SDK
source /usr/share/google-cloud-sdk/completion.zsh.inc

# kubectl completion
if (( $+commands[gopass] )); then
  if [ ! -f "$ZDOTDIR/functions/_kubectl" ]; then
    kubectl completion zsh > "$ZDOTDIR/functions/_kubectl"
  fi
fi

# gopass completion
if (( $+commands[gopass] )); then
  if [ ! -f "$ZDOTDIR/functions/_gopass" ]; then
    gopass completion zsh | head -n -1 | tail -n +2 > "$ZDOTDIR/functions/_gopass"
  fi
  compdef _gopass gopass
fi
