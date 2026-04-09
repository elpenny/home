# Bootstrap Scripts

## `bootstrap-core.sh`

Installs the shared shell baseline and applies the managed dotfiles with `stow`.

Current baseline:

- `zsh`
- `stow`
- `starship`
- `fzf`
- `ripgrep`
- `direnv`
- best-effort installation of `bat`, `fd`, `eza`, `zoxide`, and `delta`

Usage:

```bash
./scripts/bootstrap-core.sh
DEBUG=1 ./scripts/bootstrap-core.sh
```

## `bootstrap-extra.sh`

Installs optional heavier developer tooling:

- `nvm`
- `uv`
- Claude Code
- OpenAI Codex

Usage:

```bash
./scripts/bootstrap-extra.sh
./scripts/bootstrap-extra.sh --codex
./scripts/bootstrap-extra.sh --uv --claude
```

Available flags:

- `--nvm`
- `--uv`
- `--claude`
- `--codex`

With no flags, the script installs all extras. If `npm` is not already available, installing Codex first installs a Node.js LTS release through `nvm`.

## `dotnet-install.sh`

Microsoft's official `.NET` installer script. Keep it separate from the shared shell bootstrap.
