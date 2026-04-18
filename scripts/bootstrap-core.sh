#!/usr/bin/env bash
set -euo pipefail

[ "${DEBUG:-0}" -ne 0 ] && set -x

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

apt_install_if_available() {
    local pkg
    for pkg in "$@"; do
        if apt-cache show "$pkg" >/dev/null 2>&1; then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
            return 0
        fi
    done
    return 1
}

install_packages() {
    local pm="$1"
    case "$pm" in
        apt-get)
            sudo apt-get update
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
                zsh git curl ca-certificates unzip stow fzf ripgrep direnv
            apt_install_if_available bat batcat || true
            apt_install_if_available fd-find fd || true
            apt_install_if_available eza exa || true
            apt_install_if_available zoxide || true
            apt_install_if_available delta git-delta || true
            ;;
        dnf)
            sudo dnf install -y zsh git curl ca-certificates unzip stow fzf ripgrep bat fd-find direnv zoxide || true
            ;;
        yum)
            sudo yum install -y zsh git curl ca-certificates unzip stow fzf ripgrep || true
            ;;
        pacman)
            sudo pacman -Sy --noconfirm zsh git curl ca-certificates unzip stow fzf ripgrep bat fd eza zoxide direnv
            ;;
        *)
            echo "Unsupported package manager: $pm" >&2
            return 1
            ;;
    esac
}

install_starship() {
    if command_exists starship; then
        echo "starship already installed"
        return 0
    fi

    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
}

backup_stow_conflicts() {
    local backup_root="$HOME/.bootstrap-core-backup/$(date +%Y%m%d-%H%M%S)"
    local package
    local source
    local rel_path
    local target
    local backup_path
    local moved=0

    for package in "$@"; do
        while IFS= read -r source; do
            rel_path="${source#"$REPO_DIR/$package/"}"
            target="$HOME/$rel_path"

            if [ -e "$target" ] && [ ! -L "$target" ]; then
                backup_path="$backup_root/$rel_path"
                mkdir -p "$(dirname "$backup_path")"
                mv "$target" "$backup_path"
                printf 'Moved existing %s to %s\n' "$target" "$backup_path"
                moved=1
            fi
        done < <(find "$REPO_DIR/$package" -type f -o -type l)
    done

    if [ "$moved" -eq 1 ]; then
        echo "Backed up conflicting files under $backup_root"
    fi
}

apply_stow() {
    local packages=()
    local package

    command_exists stow || {
        echo "stow is required but not installed" >&2
        exit 1
    }

    mkdir -p "$HOME/.config" "$HOME/.local/bin"

    for package in bash shell git zsh starship claude; do
        [ -d "$REPO_DIR/$package" ] && packages+=("$package")
    done

    if [ "${#packages[@]}" -eq 0 ]; then
        echo "No stow packages found in $REPO_DIR" >&2
        exit 1
    fi

    backup_stow_conflicts "${packages[@]}"
    stow --dir "$REPO_DIR" --target "$HOME" "${packages[@]}"
}

main() {
    local pm
    pm="$(detect_package_manager)" || {
        echo "No supported package manager found (apt-get, dnf, yum, pacman)" >&2
        exit 1
    }

    install_packages "$pm"
    install_starship
    apply_stow

    echo "Core bootstrap complete. Start a new shell or run: exec zsh -l"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
