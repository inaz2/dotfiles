umask 022
ulimit -c 0
shopt -u sourcepath

if [[ "$PS1" ]]; then
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

    function prompt_cmd {
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
    PS1="\n\[\e[33m\]\u@\h:\[\e[39m\]\w\n\$ "

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias l='less'
    alias grep='LC_CTYPE=C grep --color=auto'
    alias ox='od -Ax -tx1z'
    alias emacs='TERM=xterm-256color emacs -nw -rv'
    alias wget='wget --no-check-certificate'
fi
