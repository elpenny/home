#!/usr/bin/env bash
set -euo pipefail

[ "${DEBUG:-0}" -ne 0 ] && set -x

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        echo "nvm already installed"
        return 0
    fi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
}

install_uv() {
    if command_exists uv; then
        echo "uv already installed"
        return 0
    fi
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_claude_code() {
    if command_exists claude; then
        echo "Claude Code already installed"
        return 0
    fi
    curl -fsSL https://claude.ai/install.sh | bash
}

main() {
    install_nvm
    install_uv
    install_claude_code

    echo "Extra bootstrap complete."
}

main "$@"
