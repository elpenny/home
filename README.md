# Home Dotfiles

Personal Linux setup for zsh + powerlevel10k with nvm and uv. The repo is intended to live at `~` so tracked files land directly in the home directory.

## Bootstrap
- Run `./install.sh` from this directory. It will install zsh, powerlevel10k, nvm, and uv, copy the shared `~/.local/bin/env`, and switch your login shell to zsh (set `SKIP_CHSH=1` to skip).
- Start a new terminal after the script finishes so zsh loads the new config.

## Fresh machine workflow
If you want to keep the repo directly on `$HOME`, clone it as a bare/separate git dir to avoid conflicts with existing files:
```
REPO_URL=<your-remote-url>
git clone --separate-git-dir=$HOME/.home-git "$REPO_URL" $HOME/.home-tmp
cp -a $HOME/.home-tmp/. $HOME/
rm -rf $HOME/.home-tmp
alias home='git --git-dir=$HOME/.home-git --work-tree=$HOME'
home checkout
home config status.showUntrackedFiles no
```
Afterwards, run `./install.sh`.

## Notes
- `.gitignore` intentionally excludes credential-bearing locations (e.g., `.ssh/`, `.aws/`, `.config/`) and caches.
- zsh sources `~/.local/bin/env`, nvm, and powerlevel10k if present. Customize the prompt by editing `~/.p10k.zsh` or running `p10k configure`.
