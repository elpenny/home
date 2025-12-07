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
    local custom_root="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local target="$custom_root/themes/powerlevel10k"
    local legacy="$HOME/.local/share/powerlevel10k"

    if [ ! -d "$target" ] && [ -d "$legacy/.git" ]; then
        mkdir -p "$(dirname "$target")"
        ln -snf "$legacy" "$target"
    fi

    if [ -d "$target/.git" ]; then
        git -C "$target" pull --ff-only
    else
        mkdir -p "$(dirname "$target")"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$target"
    fi
}

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed"
        return 0
    fi

    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_zshrc() {
    if [ -f "$HOME/.zshrc" ]; then
        echo "Existing .zshrc detected; ensure it sources oh-my-zsh and powerlevel10k if desired"
        return 0
    fi

    cat >"$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source "$ZSH/oh-my-zsh.sh"

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
EOF
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
    install_oh_my_zsh
    install_powerlevel10k
    ensure_zshrc
    install_nvm
    install_uv
    install_claude_code
    maybe_set_default_shell

    echo "Bootstrap complete. Start a new shell to load zsh + powerlevel10k + nvm + uv + claude."
}

main "$@"
