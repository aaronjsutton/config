autoload -Uz add-zsh-hook vcs_info
autoload -Uz compinit && compinit
autoload -z edit-command-line
autoload bashcompinit && bashcompinit

zle -N edit-command-line

bindkey -v
bindkey -M vicmd v edit-command-line

alias clear=':';
alias j='just';
alias t='tmux';
alias b='btop';
alias vi='nvim';
alias vim='nvim';
alias ls='eza';
alias z='zoxide';

vz() {
	fzf -q "${*:-}" --bind 'enter:become(nvim {})'
}

eval $(/opt/homebrew/bin/brew shellenv)
