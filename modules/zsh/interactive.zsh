autoload -z edit-command-line

zle -N edit-command-line

bindkey -v
bindkey -M vicmd v edit-command-line

alias ag='rg'
alias j='just'
alias la='eza --all'
alias ll='eza --long'
alias ls='eza'
alias lt='eza --tree'
alias nq='networkquality'
alias ns='networksetup'
alias top='btop'
alias vi='nvim'
alias vim='nvim'

if [[ -f "/opt/homebrew/bin/brew" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi;

if (( $+commands[zoxide] )); then
	eval "$(zoxide init zsh)"
fi;

vz() {
	fzf -q "${*:-}" --bind 'enter:become(nvim {})'
}

