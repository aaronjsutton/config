autoload -z edit-command-line
autoload -U promptinit && promptinit

setopt prompt_sp
PS1="%B%n%b@%m %1~ %(?.%F{2}❯.%F{1}❯)%f "

zle -N edit-command-line

bindkey -v
bindkey -M vicmd v edit-command-line

if (( $+commands[shadowenv] )); then
  eval "$(shadowenv init zsh)"
fi

vz() {
	fzf -q "${*:-}" --bind 'enter:become(nvim {})'
}

