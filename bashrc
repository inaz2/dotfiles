umask 022
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
    __set_xterm_title='\[\033]0;\u@\h:\w\007\]'
    __set_screen_title='\[\033k\h\033\134\]'
    __ssh_connection=($SSH_CONNECTION)
    PS1="${__set_xterm_title}\n\[\e[33m\]\u@${__ssh_connection[2]:-localhost}:\[\e[0m\]\w \[\e[36m\]\$(git_status)\[\e[0m\]\n${__set_screen_title}\$ "

    PROMPT_COMMAND='history -a'
    trap 'echo -e "\e[41mexit $?\e[0m"' ERR

    eval "$(dircolors -b)"

    # let "M-/" cycle the list of possible completions
    bind '"\e/":menu-complete'

    # let "C-b" change the current directory to $OLDPWD
    bind '"\C-b":"\ercd -\n"'

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias grep='LC_ALL=C grep --color=auto'
    alias sort='LC_ALL=C sort'
    alias ox='od -Ax -tx1z'
    alias objdump='objdump -M intel'
    alias gdb='gdb -q -ex "set disassembly-flavor intel" -ex "disp/i \$pc"'
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
            ps auxww | LC_CTYPE=C grep --color=auto "$*"
        else
            ps aux
        fi
    }

    h() {
        if [[ $# -gt 0 ]]; then
            history | LC_CTYPE=C grep --color=auto "$*"
        else
            history 50
        fi
    }

    cutf() {
        sed -E 's/\s+/ /g' | cut -d ' ' -f "$@"
    }

    diffu() {
        local DIFF
        if type -p git >/dev/null 2>&1; then
            DIFF="git diff --no-index"
        else
            DIFF="diff -u"
        fi
        if [[ $# -eq 1 ]]; then
            $DIFF "$1~" "$1"
        else
            $DIFF "$@"
        fi
    }

    dropcolor() {
        sed -E 's/\x1b\[[0-9;]+m//g' "$@"
    }

    pack() {
        echo "$*" | perl -ne 's/([0-9A-F]{2})/print pack("H2",$1)/eig'
    }

    grepb() {
        grep -boa $@ | awk -F: '{printf "0x%x\n", $1}'
    }

    rotn() {
        local TABLE='ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'
        for i in $(seq 26); do
            echo "$*" | tr "${TABLE:0:26}${TABLE:52:26}" "${TABLE:$i:26}${TABLE:52+$i:26}"
        done
    }

    xlines() {
        if [[ "$1" == "-1" ]]; then
            shift
            while read; do echo -n "$REPLY" | "$@"; echo; done
        else
            while read; do echo -n "$REPLY" | "$@"; done
        fi
    }

    asm() {
        if [[ "$1" == "-d" ]]; then
            shift
            local TEMPFILE=$(mktemp)
            echo -n "$*" > "$TEMPFILE"
            objdump -M intel -D -b binary -m i386 "$TEMPFILE" | tail -n+8
            rm -f "$TEMPFILE"
        else
            echo "$*" | as -msyntax=intel -mnaked-reg -aln -o /dev/null
        fi
    }
fi
