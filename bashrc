umask 022
ulimit -c 0
shopt -u sourcepath

if [[ -n "$PS1" ]]; then
    export LANG=en_US.UTF-8
    export EDITOR=vi
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

    git_status() {
        local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
        if [[ -n "$branch" ]]; then
            local status="$(git status --short --untracked-files=no 2>/dev/null)"
            if [[ -n "$status" ]]; then
                echo "** $branch"
            else
                echo "-- $branch"
            fi
        fi
    }
    PS1=$'\n\[\e[33m\]\u@\h:\[\e[0m\]\w \[\e[36m\]$(git_status)\[\e[0m\]\n\$ '

    __precmd_hook() {
        local s=$?
        trap __preexec_hook DEBUG
        precmd $s
    }
    __preexec_hook() {
        trap - DEBUG
        preexec "$BASH_COMMAND"
    }
    PROMPT_COMMAND=__precmd_hook

    precmd() {
        history -a
        if [[ $1 -ne 0 ]]; then
            echo -e "\e[41mexit $1\e[0m"
        fi
        if [[ "$TERM" =~ ^xterm ]]; then
            echo -en "\033]0;$USER@$HOSTNAME\007"
        fi
        if [[ "$STY" ]]; then
            echo -en "\033k${PWD##*/}\033\0134"
        fi
    }
    preexec() {
        if [[ "$STY" ]]; then
            echo -en "\033k!${1%% *}\033\0134"
        fi
    }

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias grep='LC_CTYPE=C grep --color=auto'
    alias ox='od -Ax -tx1z'
    alias ec='emacsclient -t --alternate-editor=""'
    alias wget='wget --no-check-certificate'

    l() {
        # stdin is a terminal and the first argument is nothing or a directory
        if [[ (-t 0) && ($# -eq 0 || -d "$1") ]]; then
            ls -ACF --color=auto "$@"
        else
            ${PAGER:-less} "$@"
        fi
    }

    p() {
        if [[ $# -gt 0 ]]; then
            ps auxww | LC_CTYPE=C grep --color=auto "$@"
        else
            ps aux
        fi
    }

    h() {
        if [[ $# -gt 0 ]]; then
            history | LC_CTYPE=C grep --color=auto "$@"
        else
            history 50
        fi
    }

    eval $(dircolors -b)

    # let "M-/" cycle the list of possible completions
    bind '"\e/":menu-complete'
fi
