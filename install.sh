#!/bin/sh
# ---------------------------------------------------------------------------
# dotfiles — install.sh
#
# Idempotent, non-destructive, distribution-aware installer for ~/dotfiles.
#
# Supported distributions: Fedora, Arch/CachyOS, NixOS (symlinks only;
#   packages are handled declaratively on NixOS — see bootstrap/nixos/).
#
# Usage
#   ./install.sh                 link all managed configuration
#   ./install.sh --packages      also install the recommended packages
#   ./install.sh --dry-run       show what would change without changing it
#   ./install.sh --check         report link status only
#   ./install.sh --help          this help
#
# Safety guarantees
#   * Never overwrites an existing user file: anything in the way is copied
#     to ~/dotfiles/backups/<timestamp>/ before being replaced.
#   * Safe to run repeatedly — links are only (re)created when needed.
#   * Only touches paths listed in LINK_... tables below.
# ---------------------------------------------------------------------------

set -u

# shellcheck disable=SC1091
. "$(dirname -- "$0")/bootstrap/common.sh"

# Resolve the repo root from the script location (absolute, symlink-aware).
DOTFILES_ROOT=$(dotfiles_root "$0")

# ---------------------------------------------------------------------------
# Options
# ---------------------------------------------------------------------------
DRY_RUN=0
DO_PACKAGES=0
DO_CHECK=0
DO_HELP=0
for arg in "$@"; do
    case "$arg" in
        --packages) DO_PACKAGES=1 ;;
        --dry-run)  DRY_RUN=1 ;;
        --check)    DO_CHECK=1 ;;
        --help|-h)  DO_HELP=1 ;;
        *) printf 'unknown option: %s\n' "$arg"; DO_HELP=1 ;;
    esac
done

if [ "$DO_HELP" = 1 ]; then
    grep '^#' "$0" | grep -v '#!' | sed 's/^# \{0,1\}//'
    exit 0
fi

# --check is a read-only dry run.
if [ "$DO_CHECK" = 1 ]; then
    DRY_RUN=1
fi
detect_os

info "dotfiles root : $DOTFILES_ROOT"
info "distribution  : $DOTFILES_OS"
info "package mgr   : $DOTFILES_PKG"

# ---------------------------------------------------------------------------
# Link table:  repo file  ->  $HOME location
# ---------------------------------------------------------------------------
# Home-level files (shell, git).
link_dotfile "home/.bashrc"            "$HOME/.bashrc"
link_dotfile "home/.bash_profile"      "$HOME/.bash_profile"
link_dotfile "home/.bash_logout"       "$HOME/.bash_logout"
link_dotfile "home/.gitconfig"         "$HOME/.gitconfig"

# Applications: .desktop entries.
want_dir "$HOME/.local/share/applications"
link_dotfile "home/.local/share/applications/yazi.desktop" \
    "$HOME/.local/share/applications/yazi.desktop"

# Hyprland — the Lua config loader reads this exact path.
# NOTE: this Hyprland build loads ~/.config/hyprland.lua (no `hypr/` dir).
link_dotfile "config/hypr/hyprland.lua" "$HOME/.config/hyprland.lua"

# Quickshell — whole config dir (shell.qml found by `qs`).
link_dotfile "config/quickshell" "$HOME/.config/quickshell"

# Kitty — modern path (preferred) plus the legacy path for older versions.
link_dotfile "config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_dotfile "config/kitty/kitty.conf" "$HOME/.config/kitty.conf"

# Fish — only config.fish is managed; fish_variables stays machine-local.
want_dir "$HOME/.config/fish"
link_dotfile "config/fish/config.fish" "$HOME/.config/fish/config.fish"

# Neovim — whole config dir.
link_dotfile "config/nvim" "$HOME/.config/nvim"

# ---------------------------------------------------------------------------
# Packages (optional, never automatic).
# ---------------------------------------------------------------------------
if [ "$DO_PACKAGES" = 1 ]; then
    case "$DOTFILES_OS" in
        fedora)
            info "installing packages with dnf (may ask for your password)"
            # shellcheck disable=SC2015
            has_cmd sudo && sudo dnf install -y $(grep -v '^\s*#' "$DOTFILES_ROOT/bootstrap/packages/fedora.txt" | tr '\n' ' ') \
                || dnf install -y $(grep -v '^\s*#' "$DOTFILES_ROOT/bootstrap/packages/fedora.txt" | tr '\n' ' ')
            ;;
        arch)
            info "installing packages with pacman (may ask for your password)"
            # shellcheck disable=SC2015
            has_cmd sudo && sudo pacman -S --needed --noconfirm $(grep -v '^\s*#' "$DOTFILES_ROOT/bootstrap/packages/arch.txt" | tr '\n' ' ') \
                || pacman -S --needed --noconfirm $(grep -v '^\s*#' "$DOTFILES_ROOT/bootstrap/packages/arch.txt" | tr '\n' ' ')
            ;;
        nixos)
            warn "NixOS manages packages declaratively. See bootstrap/nixos/ for a home-manager snippet."
            ;;
        *)
            warn "unknown distribution; skipping package installation."
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# Post-link user guidance.
# ---------------------------------------------------------------------------
printf '\n'
ok "Done."
printf '  * New shell config applies to new shells (re-login or spawn a new terminal).\n'
printf '  * Hyprland & Quickshell changes apply after your next login (SUPER+M or log out).\n'
printf '  * Files replaced during linking are kept in %s/backups/\n' "$DOTFILES_ROOT"
printf '  * To remove all managed links again: %s/uninstall.sh\n' "$DOTFILES_ROOT"