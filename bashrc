reset_prompt () {
    if ncol="$(tput colors 2>/dev/null)" && [ "$ncol" -gt 2 ]; then
        local yellow=$(tput setaf 3)
        local red=$(tput setaf 1)
        local white=$(tput setaf 7)
        local reset=$(tput sgr0)

        local hcol="$yellow"
        local ucol="$white"
        if [[ ${EUID} == 0 ]]; then
            local ucol="$red"
        fi

        PS1="\\[$hcol\\]\\h:\\[$ucol\\]\\w/\\$\\[$reset\\] "
    else
        PS1='\h:\w/\$ '
    fi
}

# rxvt-unicode-256color not always present in terminfo:
# try removing '-unicode' from name if no entry.
if [ `(tput 2>/dev/null; echo $?)` -eq 3 ]; then
    typeset -x TERM="${TERM/-unicode/}";
fi

[[ $- =~ "i" ]] && reset_prompt

HISTFILE="$HOME/.bash_history"
HISTSIZE=2000
SAVEHIST=4000

[ -x ~/bin/ssh-agent-env ] && . ~/bin/ssh-agent-env
[ -f ~/.env_common ] && . ~/.env_common

