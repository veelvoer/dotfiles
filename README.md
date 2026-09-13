# dotfiles

Personal, portable configuration — backed by a managed-repo layout that works
on **Fedora**, **Arch/CachyOS**, and **NixOS**.

## What's managed

| Thing             | Repo path                                  | Live location                              |
| ----------------- | ------------------------------------------ | ------------------------------------------ |
| Fish              | `config/fish/config.fish`                  | `~/.config/fish/config.fish`               |
| Hyprland (Lua)    | `config/hypr/hyprland.lua`                 | `~/.config/hyprland.lua`                   |
| Quickshell bar    | `config/quickshell/` (dir)                 | `~/.config/quickshell/`                    |
| Kitty             | `config/kitty/kitty.conf`                  | `~/.config/kitty/kitty.conf` (+ legacy)    |
| Neovim            | `config/nvim/` (dir)                       | `~/.config/nvim/`                          |
| VSCodium          | `config/vscodium/` (files)                 | `~/.config/VSCodium/User/…` + `mountain-theme.css` |
| GTK file dialog   | `config/gtk-3.0/bookmarks`                 | `~/.config/gtk-3.0/bookmarks`              |
| Shell fallbacks   | `home/.bashrc`, `.bash_profile`, `.bash_logout` | `~/.bashrc`, …                     |
| Git               | `home/.gitconfig`                          | `~/.gitconfig`                             |
| Launcher entry    | `home/.local/share/applications/yazi.desktop` | `~/.local/share/applications/yazi.desktop` |

### About `~/.config/hyprland.lua`
This Hyprland build loads its Lua config **directly from `~/.config/hyprland.lua`**
(no `hypr/` subdirectory). Do not "fix" it into `~/.config/hypr/` without
re-verifying Hyprland picks it up — the symlink to the flat path is intentional.

### Machine-local by design (never linked)
`~/.config/fish/fish_variables`, `~/.ssh/`, `~/.config/gh/hosts.yml`,
app caches, `~/.local/share` app data, `.opencode`, VSCodium app data
(`User/History`, `workspaceStorage`, caches — its `settings.json`/`keybindings.json`
*are* managed). These are recreated or live only on the machine.

## Install

```sh
cd ~/dotfiles
./install.sh            # create symlinks (backs up anything in the way)
./install.sh --full     # symlinks + recommended packages + set fish as default shell
```

Idempotent and safe:
- existing user files are **copied** to `./backups/<timestamp>/` first;
- only symlinks pointing into this repo are ever touched again;
- `--dry-run` previews, `./uninstall.sh` reverses.

## Uninstall

```sh
./uninstall.sh          # remove managed links, restore newest backups
./uninstall.sh --clean  # ... and drop ./backups afterwards
```

## Cross-distribution

- **Fedora** — `./install.sh --packages` uses `dnf`. Quickshell needs
  the Copr repo first (see `bootstrap/packages/fedora.txt`).
- **Arch / CachyOS** — `./install.sh --packages` uses `pacman`. Quickshell
  comes from the AUR (`quickshell-git`).
- **NixOS** — packages are declared, never installed imperatively. Link the
  config via `home.file` using the snippet in
  [`bootstrap/nixos/home-manager.nix`](bootstrap/nixos/home-manager.nix).

## Secrets

`secrets.example/` holds templates only. Real credentials (`~/.ssh/`,
`~/.config/gh/hosts.yml`) are excluded by `.gitignore` and must stay
machine-local. Never commit them.

## Layout

```
~/dotfiles
├── install.sh / uninstall.sh   # management scripts
├── bootstrap/                  # per-distro helpers + package lists
│   ├── common.sh
│   ├── packages/{fedora,arch}.txt
│   └── nixos/home-manager.nix
├── config/                     # app configuration (linked)
├── home/                       # $HOME-dotted files (linked)
├── secrets.example/            # templates, never real secrets
├── backups/                    # auto-created, git-ignored
└── .gitignore
```