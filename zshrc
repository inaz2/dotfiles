# stty sane erase ^? intr ^C eof ^D susp ^Z quit ^\\ start ^- stop ^-
stty sane

export LANG=C.UTF-8
unset MAIL

HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

bindkey -e

autoload -U compinit
compinit
autoload -U colors
colors
zstyle ':completion:*' menu select

# setopt autocd
setopt extended_glob
setopt append_history
setopt nomatch
setopt no_beep
setopt notify

setopt auto_menu
setopt list_types
setopt share_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt auto_pushd
setopt pushd_ignore_dups
setopt prompt_subst
setopt magic_equal_subst
setopt print_eight_bit

git_branch() {
    local ref=$(git symbolic-ref HEAD 2>/dev/null)
    if [[ -n "$ref" ]]; then
        printf "${1:-%s}" "${ref##*/}"
    fi
}
PROMPT="%(?..%{$bg[red]%}exit %?%{$reset_color%}
)
%{$fg[yellow]%}%n@%m%{$reset_color%}%# "
RPROMPT="%{$fg[cyan]%}\$(git_branch '(%s)') %{$fg_bold[white]%}[%~]%{$reset_color%}"

if [[ "$TERM" =~ ^screen ]]; then
    preexec() {
        echo -en "\033k${1%% *}\033\0134"
    }
    precmd() {
        echo -en "\033k${PWD##*/}\033\0134"
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

eval $(dircolors -b)
