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

Usage:

```bash
./scripts/bootstrap-extra.sh
```

## `dotnet-install.sh`

Microsoft's official `.NET` installer script. Keep it separate from the shared shell bootstrap.
