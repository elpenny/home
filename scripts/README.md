# Bootstrap Scripts

Development environment setup and installation scripts.

## install.sh

Automated bootstrap script for setting up a complete development environment on Linux systems.

### What It Installs

- **Shell Environment**
  - zsh shell
  - oh-my-zsh framework
  - powerlevel10k theme

- **Development Tools**
  - nvm (Node Version Manager)
  - uv (Python package installer)
  - Claude Code (AI coding assistant)

- **Base Utilities**
  - git, curl, ca-certificates
  - powerline fonts

### Supported Systems

- Debian/Ubuntu (apt-get)
- Fedora (dnf)
- CentOS/RHEL (yum)
- Arch Linux (pacman)

### Usage

```bash
# Basic usage
./install.sh

# With debug output
DEBUG=1 ./install.sh

# Skip changing default shell
SKIP_CHSH=1 ./install.sh
```

### What It Does

1. Detects your package manager
2. Installs base packages (zsh, git, curl, fonts)
3. Copies local environment scripts (if present)
4. Installs oh-my-zsh (non-interactively)
5. Installs powerlevel10k theme
6. Creates/preserves .zshrc configuration
7. Installs nvm for Node.js management
8. Installs uv for Python package management
9. Installs Claude Code CLI
10. Optionally sets zsh as default shell

### Features

- **Idempotent**: Safe to run multiple times
- **Non-interactive**: No prompts during installation
- **Preserves existing configs**: Won't overwrite your .zshrc
- **Error handling**: Exits on any failure (`set -euo pipefail`)

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `0` | Enable bash debug output (`set -x`) |
| `SKIP_CHSH` | unset | Skip changing default shell to zsh |

### Post-Installation

After installation completes:

```bash
# Start a new shell to load everything
exec zsh

# Or logout and login again
```

If this is your first time with powerlevel10k, run:
```bash
p10k configure
```

### Security Notes

This script pipes remote content to shell interpreters for:
- oh-my-zsh installation
- nvm installation
- uv installation
- Claude Code installation

While this is standard practice for these tools, understand the security implications. All sources use HTTPS, but consider reviewing the remote scripts before running.

### Troubleshooting

**Package manager not found:**
```
No supported package manager found (apt-get, dnf, yum, pacman)
```
You'll need to manually install dependencies or add support for your package manager.

**Permission denied when changing shell:**
```
chsh: PAM: Authentication failure
```
Either enter your password when prompted or use `SKIP_CHSH=1` to skip this step.

**Existing .zshrc:**
The script preserves existing .zshrc files. Manually add these lines if needed:
```bash
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source "$ZSH/oh-my-zsh.sh"
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
```

## Other Scripts

### dotnet-install.sh

Microsoft's official .NET SDK installer script. See [Microsoft documentation](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script) for usage.

## Contributing

To modify the bootstrap process:

1. Test changes in a clean environment (VM or container)
2. Ensure idempotency is maintained
3. Update this README with any new features or dependencies
