zmodload zsh/terminfo

bindkey -e # Use emacs key bindings

# [Home], [End], [Delete]
bindkey "^[[1~" beginning-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[OF" end-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char-or-list

bindkey "^[[1;5C" forward-word                    # [Ctrl-RightArrow] - move forward one word
bindkey "^[[1;5D" backward-word                   # [Ctrl-LeftArrow] - move backward one word
bindkey "^[[3;5~" kill-word                       # [Ctrl+Delete] - kill word next to cursor
bindkey "^H" backward-kill-word                   # [Ctrl+Backspace] - kill word prev to cursor

bindkey "${terminfo[kcbt]}" reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards

# zsh-users/zsh-history-substring-search
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "^[[A" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey "^[[B" history-substring-search-down

# fzf
bindkey '^T' fzf-completion
bindkey '^I' fzf-completion

join-lines() {
	local item
	while read item; do
		echo -n "${(q)item} "
	done
}

_bind-git-helper() {
	local char
	for c in $@; do
		eval "fzf-g$c-widget() { local result=\$(g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
		eval "zle -N fzf-g$c-widget"
		eval "bindkey '^g^$c' fzf-g$c-widget"
	done
}
_bind-git-helper f b t r h
unset -f _bind-git-helper

source "${ZPLUGINSDIR}/fzf/shell/key-bindings.zsh"
