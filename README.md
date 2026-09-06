# dotfiles

Personal configuration for [Omarchy](https://omarchy.org), managed with
[chezmoi](https://chezmoi.io).

This is a fresh start. The previous incarnation of this repo — a Ruby script
that hardlinked and symlinked files into `$HOME` — lives on the `omarchy`
branch and shares no history with this one.

## Bootstrap a new machine

```sh
sudo pacman -S --needed chezmoi
chezmoi init --apply --branch chezmoi https://github.com/flavorjones/dotfiles.git
omarchy-recipe
```

Once this branch becomes the default branch, the second command shortens to
`chezmoi init --apply flavorjones`.

## Packages

`chezmoi apply` only writes files. It deliberately does not install packages,
because that needs `sudo` and should not happen behind your back on every
apply.

Packages are installed by `omarchy-recipe`, whose source is
`home/dot_local/bin/executable_omarchy-recipe`. Add a package by adding a line
to the `PACKAGES` array in that script, then run it.

The script is idempotent. It checks the local package database first and only
calls `yay` for what is missing, so a run with nothing to do never asks for a
password. `yay` covers both the Arch repos and the AUR, so one list is enough.

## GitHub authentication

Git talks to GitHub over SSH, with the key held in 1Password.

`~/.ssh/config` points ssh at the 1Password agent socket, and `.gitconfig_generic`
rewrites `https://github.com/` to `git@github.com:` at use time. So an https
remote still authenticates with the 1Password key, and nothing has to be
re-cloned. No credential helper and no stored token is involved.

This depends on one setting that only exists in the 1Password GUI:
**Settings > Developer > Use the SSH agent**. Without it the socket file still
exists but refuses connections, and every push fails with
`Permission denied (publickey)` — which looks nothing like a 1Password problem.

`omarchy-recipe` checks for exactly this and tells you how to fix it, so it does
not need remembering.

## Design rules

1. **Omarchy is the only target.** No macOS, no other distribution. Do not add
   portability machinery for platforms that are not in use.
2. **Never take ownership of a file Omarchy owns.** Omarchy rewrites its own
   files on upgrade, and a managed copy would either be clobbered or would
   block the upgrade. Use Omarchy's extension points instead — `~/.config/omarchy/`
   holds `defaults/`, `themed/`, `extensions/`, `hooks/`, and `etc-overrides/`.
   Where no extension point exists, use a chezmoi `modify_` script to edit the
   existing file in place rather than replacing it.
3. **No secrets in this repo, not even encrypted.** Secrets live in 1Password
   and are read at apply time through the `op` CLI, via chezmoi's `onepasswordRead`
   and related template functions.
4. **Everything is idempotent.** `chezmoi apply` must be safe to run any number
   of times, and must produce the same result on a brand-new machine.

## Layout

```
.chezmoiroot        contains "home", so the chezmoi source directory is home/
home/               the chezmoi source state — everything under here maps to $HOME
README.md           this file
```

Notable files inside `home/`:

```
dot_config/hypr/input.lua             keyboard and touchpad overrides for Hyprland
dot_local/bin/executable_omarchy-recipe   the package installer described above
```

Keeping the source state in `home/` leaves the repository root free for
documentation and repository metadata, which chezmoi then never tries to apply.

## Everyday commands

| Command | What it does |
| --- | --- |
| `chezmoi diff` | Show what `apply` would change. Always run this first. |
| `chezmoi status` | Short form of the same, one line per file. |
| `chezmoi apply` | Write the source state to `$HOME`. |
| `chezmoi add <path>` | Copy an existing file in `$HOME` into the source state. |
| `chezmoi edit <path>` | Edit the source file that produces `<path>`. |
| `chezmoi re-add` | Pull edits made directly in `$HOME` back into the source. |
| `chezmoi managed` | List every path chezmoi controls. |
| `chezmoi cd` | Open a shell in the source directory. |
| `chezmoi doctor` | Check the local setup for problems. |

## Source file naming

chezmoi encodes file attributes in the source filename. The common prefixes:

| Source name | Result in `$HOME` |
| --- | --- |
| `dot_bashrc` | `.bashrc` |
| `private_dot_ssh/` | `.ssh/`, mode `0700` |
| `executable_foo` | `foo`, mode `0755` |
| `symlink_dot_foo` | `.foo`, a symlink to the file's contents |
| `exact_dot_config/` | `.config/`, with unmanaged files deleted |
| `foo.tmpl` | `foo`, rendered as a Go template |
| `modify_foo` | `foo`, edited in place by running the script |
| `run_once_install.sh` | not a file; a script that runs one time |
| `run_onchange_install.sh` | not a file; a script that runs when its own text changes |
