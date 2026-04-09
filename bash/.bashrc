# Skip non-interactive shells.
case $- in
    *i*) ;;
    *) return;;
esac

. "$HOME/.local/bin/env"

if [ -f "$HOME/.config/shell/aliases.sh" ]; then
    . "$HOME/.config/shell/aliases.sh"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
