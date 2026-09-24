# jeffzi's Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MacOS dotfiles managed with [chezmoi](https://www.chezmoi.io) and
[Mackup](https://github.com/lra/mackup).

## Instructions

1. Give the terminal [full-disk access](https://www.alfredapp.com/help/troubleshooting/indexing/terminal-full-disk-access/).
2. Install remotely from a single shell command:

   ```sh
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/jeffzi/dotfiles/main/install.sh)"
   ```

   The script installs Homebrew, 1Password, and chezmoi. It then waits until the 1Password app
   shares its accounts with the CLI (Settings > Developer > Integrate with 1Password CLI), because
   several templates read secrets through `op`.

   `chezmoi init` asks once for the work organisation directory name under `~/Projects/work`.
   Leave it empty on a machine without work projects.

3. The initial clone uses HTTPS and is shallow. Switch the remote to SSH to push with your own
   credentials:

   ```sh
   chezmoi cd
   git remote set-url origin git@github-personal:jeffzi/dotfiles.git
   ```

4. Enable the [1Password SSH agent](https://developer.1password.com/docs/ssh/agent/).

Test it:

```bash
chezmoi cd
git pull
```
