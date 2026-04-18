# Home Dotfiles

Personal Linux and WSL shell setup managed from a normal git repo with GNU `stow`.

## Layout

Keep the repo outside of `$HOME`, for example:

```bash
git clone https://github.com/elpenny/home.git ~/repositories/home
cd ~/repositories/home
```

Tracked files are grouped into `stow` packages:

- `bash/`
- `git/`
- `shell/`
- `starship/`
- `zsh/`

Applying a package creates symlinks into `$HOME`.

## Bootstrap

Core shell and CLI setup:

```bash
./scripts/bootstrap-core.sh
```

Optional extra dev tooling:

```bash
./scripts/bootstrap-extra.sh
./scripts/bootstrap-extra.sh --codex
./scripts/bootstrap-extra.sh --uv --codex
```

`bootstrap-core.sh` installs the shell baseline, installs `starship`, and runs `stow` to link the managed files into `$HOME`.
`bootstrap-extra.sh` installs optional tools including `nvm`, `uv`, Claude Code, and OpenAI Codex. With no flags it installs all extras; pass flags to install only selected tools. If `npm` is not already available, installing Codex will first install a Node.js LTS release through `nvm`.

## Manual Stow Usage

Apply everything:

```bash
stow --dir "$HOME/repositories/home" --target "$HOME" bash shell git zsh starship
```

Remove a package:

```bash
stow --dir "$HOME/repositories/home" --target "$HOME" --delete zsh
```

## Managed Baseline

- `zsh` with `starship`
- modern CLI defaults when installed: `eza`, `bat`, `zoxide`, `fzf`, `fd`, `rg`, `delta`, `direnv`
- shared PATH handling in `~/.local/bin/env`
- shared git config and ignore rules

The shell config is defensive: optional tools are only initialized when present.

## Machine-Local Overrides

Keep machine-specific tweaks out of git.

- Put shell-only overrides in `~/.zshrc.local`
- Keep secrets and credentials in untracked locations like `~/.ssh/`, `~/.aws/`, and Windows-mounted paths
- If needed, add `~/.gitconfig.local` manually and include it from your local machine-specific setup

Examples of local-only content:

- Google Cloud SDK paths
- WSL-only mount points
- experimental aliases
- credentials and tokens
