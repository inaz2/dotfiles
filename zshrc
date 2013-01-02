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

setopt print_eight_bit
setopt no_beep
setopt extended_glob
setopt magic_equal_subst
setopt correct
setopt nomatch
setopt auto_menu
setopt list_types
setopt auto_pushd
setopt pushd_ignore_dups
setopt prompt_subst
setopt transient_rprompt
setopt notify

git_branch() {
    local ref=$(git symbolic-ref HEAD 2>/dev/null)
    if [[ -n "$ref" ]]; then
        printf "${1:-%s}" "${ref##*/}"
    fi
}
PROMPT=$'%(?..%{\e[41m%}exit %?%{\e[0m%}\n)\n%{\e[33m%}%n@%m%{\e[0m%}:%~\n%# '
RPROMPT=$'%{\e[36m%}$(git_branch "(%s)")%{\e[0m%}'

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
