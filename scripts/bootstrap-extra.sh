#!/usr/bin/env bash
set -euo pipefail

[ "${DEBUG:-0}" -ne 0 ] && set -x

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # nvm is a shell function, so the installer must be sourced in-process.
        . "$NVM_DIR/nvm.sh"
        return 0
    fi

    echo "nvm is not available at $NVM_DIR/nvm.sh" >&2
    return 1
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

ensure_npm() {
    if command_exists npm; then
        return 0
    fi

    load_nvm

    if command_exists npm; then
        return 0
    fi

    nvm install --lts
    nvm alias default 'lts/*' >/dev/null 2>&1 || true
    nvm use --lts >/dev/null
}

install_codex() {
    if command_exists codex; then
        echo "Codex already installed"
        return 0
    fi

    ensure_npm
    npm install -g @openai/codex
}

main() {
    install_nvm
    install_uv
    install_claude_code
    install_codex

    echo "Extra bootstrap complete."
}

main "$@"
