umask 022
shopt -u sourcepath

if [[ -n "$PS1" ]]; then
    export LANG=en_US.UTF-8
    export TERM=xterm-256color
    export EDITOR=vi
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

    set -o pipefail
    trap 'echo -e "\e[41mexit ${PIPESTATUS[*]}\e[0m"' ERR

    # let "M-n/p" do partial history search
    bind '"\en":history-search-forward'
    bind '"\ep":history-search-backward'

    # let "M-/" attempt menu completion from history
    bind '"\e/":dabbrev-expand'

    # let "C-b" change the current directory to $OLDPWD
    bind '"\C-b":"\ercd -\n"'

    # let "M-h/?" open the man page / help of the command (like zsh's run-help)
    bind -x '"\eh":"[[ -n $READLINE_LINE ]] && man 1 ${READLINE_LINE%% *}"'
    bind -x '"\e?":"[[ -n $READLINE_LINE ]] && (${READLINE_LINE%% *} --help) |& ${PAGER:-less}"'

    unalias -a
    alias ls='ls -CF --color=auto'
    alias la='ls -A'
    alias ll='ls -al'
    alias ox='od -Ax -tx1z'
    alias objdump='objdump -M intel'
    alias gdb='gdb -q -x ~/.gdbinit'
    alias ec='emacsclient -t --alternate-editor=""'
    alias wget='wget --no-check-certificate'
    alias s='screen -U'

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
            ${PAGER:-less -R} "$@"
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
        find "${2:-.}" \! -type d \! -path "*/.*" -path "*$1*" |& grep -v -F ": Permission denied" | sort
    }

    cats() {
        local CODE
        read -r -d '' CODE <<"__EOF__"
import sys, locale, chardet

text = sys.stdin.read()
locale = locale.getdefaultlocale() or 'UTF-8'
result = chardet.detect(text)
sys.stdout.write(text.decode(result['encoding'], 'replace').encode(locale[1]))
__EOF__
        cat "$@" | python -c "$CODE"
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

    grepb() {
        local bytes=$(echo "$1" | perl -ne 's/([0-9A-F]{2})/print pack("H2",$1)/eig')
        shift
        grep -boa "$bytes" "$@" | awk -F: '{printf "0x%x\n", $1}'
    }

    xlines() {
        while read; do echo -n "$REPLY" | "$@"; done
    }
fi
