autoload -Uz add-zsh-hook vcs_info
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
autoload -z edit-command-line

zle -N edit-command-line

bindkey -v
bindkey -M vicmd "/" fzf-history-widget
bindkey -M vicmd v edit-command-line

PROMPT='%F{6}%n@%m %b%f%F{246}%1~%f %(?.%F{2}❯.%F{1}❯)%f '

vz() {
	fzf -q "${*:-}" --bind 'enter:become(nvim {})'
}

eval $(/opt/homebrew/bin/brew shellenv)

complete -C $(which aws_completer) aws
