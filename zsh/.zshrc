### aliases 
alias vim=nvim
alias ls='ls --color=auto'

### options
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt TRANSIENT_RPROMPT
setopt SHARE_HISTORY

### completions
_comp_options+=(globdots) # With hidden files
autoload -U compinit; compinit
source $HOME/dotfiles/zsh/completions/bd.zsh

### prompt
fpath=($HOME/dotfiles/zsh $fpath)
autoload -Uz prompt_setup; prompt_setup


### prompt profiling
# set type of SECONDS and start to float to increase precision
typeset -F SECONDS start 

# define precmd hook function
precmd () {
    # save time since start of zsh in start
    start=$SECONDS
}

zmodload zsh/mathfunc
# define zle-line-init function
zle-line-init () {
     PROMPT_TIME_IN_MS=$((int(($SECONDS - $start) * 1000)))
     # print time since start was set after prompt
     PREDISPLAY="[${PROMPT_TIME_IN_MS}ms] "
}

# link the zle-line-init widget to the function of the same name
zle -N zle-line-init

### keybinds 
bindkey '^R' history-incremental-search-backward
bindkey '^[[3~' delete-char


# pnpm
export PNPM_HOME="/home/olik/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
