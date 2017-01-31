if [ "$(tput colors)" -gt 2 ]; then
    local yellow=$(tput setaf 3)
    local red=$(tput setaf 1)
    local white=$(tput setaf 8)
    local reset=$(tput sgr0)

    local hcol="$yellow"
    local ucol="$white"
    if [[ ${EUID} == 0 ]]; then
	local ucol="$red"
    fi

    PROMPT='\[$hcol\]\h:\[$ucol\]\w/\$\[$reset\] '
else
    PROMPT='\h:\w/\$ '
fi

set_prompt

HISTFILE="$HOME/.bash_history"
HISTSIZE=2000
SAVEHIST=4000

if [ -x ~/bin/ssh-agent-env ]; then . ~/bin/ssh-agent-env; fi

. "$HOME/.env_common"

