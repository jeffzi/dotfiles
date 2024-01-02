# jeffzi's Dotfiles

MacOS dotfiles managed with [chezmoi](https://www.chezmoi.io) and
[Mackup](https://github.com/lra/mackup).

## Instructions

The username on the machine must be `jeffzi` to match
[chezmoi's configuration](home/.chezmoi.toml.tmpl) and apply dotfiles properly.

1. Give the terminal [full-disk access](https://www.alfredapp.com/help/troubleshooting/indexing/terminal-full-disk-access/).
2. Install remotely from single shell command

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jeffzi/dotfiles/main/install.sh)"
```

3. We need HTTPS for the initial clone when the dotfiles are not installed but we must
   switch to SSH to use our own credentials.

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
