stty sane erase ^\? intr ^C eof ^D susp ^Z quit ^\\ start ^- stop ^-
bindkey -e

export LANG=C.UTF-8
unset MAIL

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
REPORTTIME=3

autoload -U compinit
compinit -u
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space

setopt extended_glob
setopt auto_menu
setopt list_types
setopt magic_equal_subst
setopt correct
setopt nomatch
setopt auto_pushd
setopt pushd_ignore_dups
setopt transient_rprompt
setopt notify

setopt print_eight_bit
setopt prompt_subst
setopt sh_word_split
setopt no_beep

git_status() {
    local s="$(git status --short --branch 2>/dev/null)"
    if [[ -n "$s" ]]; then
        echo $s    # collapse sequences of whitespace into a single space
    fi
}
PROMPT=$'%(?..%{\e[41m%}exit %?%{\e[0m%}\n)\n%{\e[33m%}%n@%m%{\e[0m%}:%~\n%# '
RPROMPT=$'%{\e[36m%}$(git_status)%{\e[0m%}'

if [[ "$TERM" =~ ^screen ]]; then
    precmd() {
        echo -en "\033k${PWD##*/}\033\0134"
    }
    preexec() {
        echo -en "\033k!${BASH_COMMAND%% *}\033\0134"
    }
fi

alias ls='ls -CF --color=auto'
alias la='ls -A'
alias ll='ls -al'
alias l='less'
alias grep='LC_CTYPE=C grep --color=auto'
alias ox='od -Ax -tx1z'
alias emacs='emacs -nw -rv'
alias wget='wget --no-check-certificate'
alias psgrep='ps aux | grep'

eval $(dircolors -b)
