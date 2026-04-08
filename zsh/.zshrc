export skip_global_compinit=1

if [ -d "$HOME/.config/zsh/completions" ]; then
    fpath=("$HOME/.config/zsh/completions" $fpath)
fi

if [ -d "$HOME/.oh-my-zsh/custom/completions" ]; then
    fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
fi

if [ -d /usr/share/zsh/site-functions ]; then
    fpath=(/usr/share/zsh/site-functions $fpath)
fi

if [ -d /usr/share/zsh/vendor-completions ]; then
    _vendor_completions_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/vendor-completions"
    mkdir -p "$_vendor_completions_cache"

    for _completion_file in /usr/share/zsh/vendor-completions/_*; do
        [ -e "$_completion_file" ] || continue
        ln -snf "$_completion_file" "$_vendor_completions_cache/$(basename "$_completion_file")"
    done

    fpath=("$_vendor_completions_cache" ${fpath:#/usr/share/zsh/vendor-completions})
    unset _completion_file _vendor_completions_cache
fi

zmodload zsh/complist
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'no matches for: %d'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose true

bindkey '^I' expand-or-complete
bindkey '^[OD' backward-char
bindkey '^[OC' forward-char
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[3D' backward-word
bindkey '^[[3C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

if (( ${+terminfo[kLFT5]} )); then
    bindkey "${terminfo[kLFT5]}" backward-word
fi

if (( ${+terminfo[kRIT5]} )); then
    bindkey "${terminfo[kRIT5]}" forward-word
fi

. "$HOME/.local/bin/env"

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
export HISTFILE HISTSIZE SAVEHIST

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

if [ -f "$HOME/.config/shell/aliases.sh" ]; then
    . "$HOME/.config/shell/aliases.sh"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

if command -v aws_completer >/dev/null 2>&1; then
    autoload -Uz bashcompinit
    bashcompinit
    complete -C "$(command -v aws_completer)" aws
fi

if [ -s "$HOME/.fzf.zsh" ]; then
    . "$HOME/.fzf.zsh"
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    . /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && . /usr/share/doc/fzf/examples/completion.zsh
fi

bindkey '^I' expand-or-complete

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if [ "$TERM_PROGRAM" = "WezTerm" ]; then
    function _wezterm_pwd_name() {
        print -r -- "${PWD##*/}"
    }

    function _wezterm_set_title() {
        printf '\033]2;%s\007' "$(_wezterm_pwd_name)"
    }

    function _wezterm_osc7_pwd() {
        printf '\033]7;file://%s%s\033\\' "$HOST" "${PWD// /%20}"
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _wezterm_set_title
    add-zsh-hook chpwd _wezterm_osc7_pwd
    add-zsh-hook precmd _wezterm_set_title
    add-zsh-hook precmd _wezterm_osc7_pwd
fi

if [ -f "$HOME/.zshrc.local" ]; then
    . "$HOME/.zshrc.local"
fi
