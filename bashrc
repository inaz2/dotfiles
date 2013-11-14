umask 022
ulimit -c 0
shopt -u sourcepath

if [[ -n "$PS1" ]]; then
    export LANG=en_US.UTF-8
    export TERM=xterm-256color
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
        local status="$(git status --untracked-files=no 2>/dev/null)"
        local re_branch=$'^# On branch ([^\n]+)'
        if [[ "$status" =~ $re_branch ]]; then
            local branch="${BASH_REMATCH[1]}"
            if [[ "$status" =~ $'\nnothing to commit' ]]; then
                echo "-- $branch"
            else
                echo "** $branch"
            fi
        fi
    }
    __set_xterm_title='\[\033]0;\u@\h:\w\007\]'
    __set_screen_title='\[\033k\033\134\]'
    PS1="${__set_xterm_title}\n\[\e[33m\]\u@\h:\[\e[0m\]\w \[\e[36m\]\$(git_status)\[\e[0m\]\n${__set_screen_title}\$ "

    PROMPT_COMMAND='history -a'
    trap 'echo -e "\e[41mexit $?\e[0m"' ERR

    eval "$(dircolors -b)"

    # let "M-/" cycle the list of possible completions
    bind '"\e/":menu-complete'

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias grep='LC_CTYPE=C grep --color=auto'
    alias ox='od -Ax -tx1z'
    alias objdump='objdump -M intel'
    alias ec='emacsclient -t --alternate-editor=""'
    alias wget='wget --no-check-certificate'
    alias s='screen -U'

    l() {
        # if the argument is a single file or stdin is pipe
        if [[ ($# -eq 1 && -f "$1") || (-p /dev/stdin) ]]; then
            ${PAGER:-less} "$@"
        else
            ls -alF --color=auto "$@"
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
fi
