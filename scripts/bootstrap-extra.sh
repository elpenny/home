#!/usr/bin/env bash
set -euo pipefail

[ "${DEBUG:-0}" -ne 0 ] && set -x

INSTALL_NVM=0
INSTALL_UV=0
INSTALL_CLAUDE=0
INSTALL_CODEX=0

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<'EOF'
Usage: ./scripts/bootstrap-extra.sh [options]

Install optional developer tooling. With no options, installs all extras.

Options:
  --nvm       Install nvm
  --uv        Install uv
  --claude    Install Claude Code
  --codex     Install OpenAI Codex
  -h, --help  Show this help text
EOF
}

enable_all_installs() {
    INSTALL_NVM=1
    INSTALL_UV=1
    INSTALL_CLAUDE=1
    INSTALL_CODEX=1
}

parse_args() {
    if [ "$#" -eq 0 ]; then
        enable_all_installs
        return 0
    fi

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --nvm)
                INSTALL_NVM=1
                ;;
            --uv)
                INSTALL_UV=1
                ;;
            --claude)
                INSTALL_CLAUDE=1
                ;;
            --codex)
                INSTALL_CODEX=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
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
    parse_args "$@"

    if [ "$INSTALL_NVM" -eq 1 ] || [ "$INSTALL_CODEX" -eq 1 ]; then
        install_nvm
    fi

    if [ "$INSTALL_UV" -eq 1 ]; then
        install_uv
    fi

    if [ "$INSTALL_CLAUDE" -eq 1 ]; then
        install_claude_code
    fi

    if [ "$INSTALL_CODEX" -eq 1 ]; then
        install_codex
    fi

    echo "Extra bootstrap complete."
}

main "$@"
