umask 022
ulimit -c 0
shopt -u sourcepath

if [[ -n "$PS1" ]]; then
    export LANG=C.UTF-8
    unset MAIL

    HISTSIZE=100000
    HISTFILESIZE=100000
    HISTCONTROL=ignoreboth

    shopt -s histappend
    shopt -s histverify
    shopt -s histreedit
    shopt -s checkwinsize
    shopt -u hostcomplete
    shopt -s checkhash
    shopt -s no_empty_cmd_completion

    stty sane erase ^? intr ^C eof ^D susp ^Z quit ^\\ start ^- stop ^-

    prompt_cmd() {
        local s=$?
        history -a
        if [[ $s -ne 0 ]]; then
            echo -e "\033[41mexit $s\033[49m"
        fi
        if [[ "$TERM" =~ ^screen ]]; then
            echo -en "\033k${PWD##*/}\033\0134"
        fi
    }
    PROMPT_COMMAND=prompt_cmd

    git_branch() {
        local ref=$(git symbolic-ref HEAD 2>/dev/null)
        if [[ -n "$ref" ]]; then
            printf "${1:-%s}" "${ref##*/}"
        fi
    }
    PS1="\n\[\e[33m\]\u@\h:\[\e[0m\]\w \[\e[36m\]\$(git_branch '(%s)')\[\e[0m\]\n\$ "

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias l='less'
    alias grep='LC_CTYPE=C grep --color=auto'
    alias ox='od -Ax -tx1z'
    alias emacs='emacs -nw -rv'
    alias wget='wget --no-check-certificate'

    eval $(dircolors -b)
fi
