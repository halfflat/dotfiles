PROMPT='%F{yellow}%m:%f%(!.%F{red}.%F{white})%1d%(1~./.)%# '

HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=4000

if type nvim >&/dev/null && ! type vim >&/dev/null; then
    alias vim=nvim
    alias view="nvim -R"
fi

bindkey -e
setopt incappendhistory nomatch
unsetopt beep autocd hup

[ -x ~/bin/ssh-agent-env ] && . ~/bin/ssh-agent-env

autoload -Uz compinit
compinit
