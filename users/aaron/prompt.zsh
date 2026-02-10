autoload -U promptinit && promptinit

setopt prompt_sp

PS1='%F{244}%n%F{241}@%m %b%f%F{247}%1~%f %(?.%F{255}❯.%F{1}❯)%f '
