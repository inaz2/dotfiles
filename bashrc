umask 022
shopt -u sourcepath

if [[ -n "$PS1" ]]; then
    export LANG=en_US.UTF-8
    export EDITOR=vi
    export LESS='--RAW-CONTROL-CHARS --LONG-PROMPT'
    unset MAIL

    HISTSIZE=1000000
    HISTCONTROL=ignoreboth
    unset HISTFILESIZE

    shopt -s histappend
    shopt -s histverify
    shopt -s histreedit
    shopt -s checkwinsize
    shopt -s checkhash
    shopt -s no_empty_cmd_completion
    shopt -u hostcomplete

    case "$TERM" in
         xterm*)
             __set_xterm_title='\[\033]0;\u@\h:\w\007\]'
             ;;
         screen*)
             if [[ -z "$STY" ]]; then
                 # if the shell is on the remote server, display hostname
                 __set_screen_title='\[\033k[\h]\033\134\]'
             else
                 # otherwise, display command name or directory name
                 __set_screen_title='\[\033k\033\134\033k\W\033\134\]'
             fi
             ;;
    esac

    __git_status() {
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
    __ssh_connection=($SSH_CONNECTION)
    PS1="\[\a\]${__set_xterm_title}\n\[\e[33m\]\u@${__ssh_connection[2]:-localhost}:\[\e[0m\]\w \[\e[36m\]\$(__git_status)\[\e[0m\]\n${__set_screen_title}\\$ "

    PROMPT_COMMAND='history -a'

    set -o pipefail
    trap 'echo -e "\e[41mexit ${PIPESTATUS[*]}\e[0m"' ERR

    # let "C-p/n" attempt completion from history
    bind '"\C-p":history-search-backward'
    bind '"\C-n":history-search-forward'

    # let "C-b" change the current directory to $OLDPWD
    bind '"\C-b":"\ercd -\n"'

    # let "M-h/?" open the man page / help of the command (like zsh's run-help)
    bind -x '"\eh":"__look_at man"'
    bind -x '"\e?":"__look_at help"'

    __look_at() {
        local line="${READLINE_LINE##sudo }"
        local cmd="${line%% *}"
        if hash "$cmd" &>/dev/null; then
            if [[ "$1" == "man" ]]; then
                man "$cmd"
            elif [[ "$1" == "help" ]]; then
                "$cmd" --help |& ${PAGER:-less}
            fi
        fi
    }

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias ox='od -Ax -tx1z'
    alias objdump='objdump -M intel'
    alias gdb='gdb -q -nh -x ~/.gdbinit'
    alias ec='TERM=xterm-256color emacsclient -nw --alternate-editor=""'
    alias wget='wget --no-check-certificate'

    grep() {
        LC_ALL=C command grep --color=auto "$@"
    }

    sort() {
        LC_ALL=C command sort "$@"
    }

    cd() {
        command cd "$@"
        local s=$?
        if [[ ($s -eq 0) && (${#FUNCNAME[*]} -eq 1) ]]; then
            history -s cd $(printf "%q" "$PWD")
        fi
        return $s
    }

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
            ps auxww | grep "$@"
        else
            ps aux
        fi
    }

    h() {
        if [[ $# -gt 0 ]]; then
            history | tac | sort -k2 -u | sort | grep "$@"
        else
            history 50
        fi
    }

    f() {
        find "${2:-$PWD}" \! -type d \! -path "*/.*" -path "*$1*" |& grep -v -F ": Permission denied" | sort
    }

    s() {
        screen -U -t "$1" "$@"
    }

    cats() {
        local CODE
        read -r -d '' CODE <<"__EOF__"
import sys, chardet

text = sys.stdin.read()
outenc = sys.stdout.encoding or 'UTF-8'
result = chardet.detect(text)
sys.stdout.write(text.decode(result['encoding'], 'replace').encode(outenc))
__EOF__
        cat "$@" | python -c "$CODE"
    }

    diffu() {
        local DIFF
        if hash git &>/dev/null; then
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

    cutf() {
        sed -E 's/\s+/ /g' | cut -d ' ' -f "$@"
    }

    grepb() {
        local bytes=$(echo "$1" | perl -ne 's/([0-9A-F]{2})/print pack("H2",$1)/eig')
        shift
        grep -boa "$bytes" "$@" | awk -F: '{printf "0x%x\n", $1}'
    }

    xlines() {
        while read; do echo -n "$REPLY" | "$@"; done
    }

    dropcolor() {
        sed -E 's/\x1b\[[0-9;]+m//g' "$@"
    }

    diffdump() {
        diff -u1 -F '>:$' -I '[0-9a-f]\{6,\}' <(objdump -d "$1" | cut -f2-) <(objdump -d "$2" | cut -f2-)
    }

    __sudo_cygwin() {
        /usr/bin/cygstart --action=runas /bin/bash -l -c "${@:-cmd}"
    }

    if [[ -x "/usr/bin/cygstart" ]]; then
        alias sudo=__sudo_cygwin
    fi
fi
