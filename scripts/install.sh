#!/usr/bin/env bash
set -euo pipefail

[ "${DEBUG:-0}" -ne 0 ] && set -x

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
    for pm in apt-get dnf yum pacman; do
        if command_exists "$pm"; then
            echo "$pm"
            return 0
        fi
    done
    return 1
}

install_base_packages() {
    local pm="$1"
    case "$pm" in
        apt-get)
            sudo apt-get update
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y zsh git curl ca-certificates fonts-powerline
            ;;
        dnf)
            sudo dnf install -y zsh git curl ca-certificates powerline-fonts
            ;;
        yum)
            sudo yum install -y zsh git curl ca-certificates powerline-fonts
            ;;
        pacman)
            sudo pacman -Sy --noconfirm zsh git curl ca-certificates powerline-fonts
            ;;
        *)
            echo "Unsupported package manager: $pm" >&2
            return 1
            ;;
    esac
}

install_powerlevel10k() {
    local target="$HOME/.local/share/powerlevel10k"
    if [ -d "$target/.git" ]; then
        git -C "$target" pull --ff-only
    else
        mkdir -p "$(dirname "$target")"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
    fi
}

install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        echo "nvm already installed"
        return 0
    fi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

install_uv() {
    if command_exists uv; then
        echo "uv already installed"
        return 0
    fi
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

ensure_local_env() {
    mkdir -p "$HOME/.local/bin"
    if [ -f "$REPO_DIR/.local/bin/env" ]; then
        cp "$REPO_DIR/.local/bin/env" "$HOME/.local/bin/env"
    fi
    chmod +x "$HOME/.local/bin/env"
}

maybe_set_default_shell() {
    if [ -n "${SKIP_CHSH:-}" ]; then
        echo "Skipping chsh because SKIP_CHSH is set"
        return 0
    fi
    if command_exists zsh && [ "$SHELL" != "$(command -v zsh)" ]; then
        echo "Setting default shell to zsh (password may be required)"
        chsh -s "$(command -v zsh)"
    fi
}

main() {
    local pm
    pm=$(detect_package_manager) || {
        echo "No supported package manager found (apt-get, dnf, yum, pacman)" >&2
        exit 1
    }

    install_base_packages "$pm"
    ensure_local_env
    install_powerlevel10k
    install_nvm
    install_uv
    maybe_set_default_shell

    echo "Bootstrap complete. Start a new shell to load zsh + powerlevel10k + nvm + uv."
}

main "$@"
