autoload -Uz add-zsh-hook vcs_info
autoload -Uz compinit && compinit
autoload -z edit-command-line

zle -N edit-command-line

bindkey -v
bindkey -M vicmd v edit-command-line

alias la='eza --all'
alias ll='eza --long'
alias ls='eza'
alias lt='eza --tree'
alias vi='nvim'
alias vim='nvim'

vz() {
	fzf -q "${*:-}" --bind 'enter:become(nvim {})'
}

eval "$(/opt/homebrew/bin/brew shellenv)"
