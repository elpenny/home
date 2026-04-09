if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza --icons=auto -lah --git --group-directories-first'
    alias la='eza --icons=auto -la --group-directories-first'
    alias lt='eza --icons=auto --tree --level=2 --group-directories-first'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
    alias cat='batcat --paging=never --style=plain'
fi

if command -v fd >/dev/null 2>&1; then
    alias ff='fd'
elif command -v fdfind >/dev/null 2>&1; then
    alias ff='fdfind'
fi

alias rlsh='exec zsh -l'
alias pathl='echo "$PATH" | tr ":" "\n"'
