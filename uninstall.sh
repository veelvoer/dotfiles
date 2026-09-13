#!/bin/sh
# ---------------------------------------------------------------------------
# dotfiles — uninstall.sh
#
# Removes the symlinks created by install.sh and, when possible, restores
# the files that were backed up before linking.
#
# Rules
#   * Only ever removes paths that are symlinks pointing into ~/dotfiles.
#   * Never touches real files or symlinks owned by other tools.
#   * Restores the newest matching backup found in ~/dotfiles/backups/.
#
# Usage
#   ./uninstall.sh            remove managed links (keeps backups)
#   ./uninstall.sh --clean    also remove the backups directory afterwards
#   ./uninstall.sh --dry-run  show what would be removed
# ---------------------------------------------------------------------------

set -u

# Expand the repo path (absolute, symlink-aware) so the link comparisons below
# are correct regardless of cwd and/or a symlinked script location.
_me=$0
while [ -L "$_me" ]; do
    _dir=$(dirname "$_me")
    _link=$(readlink "$_me")
    case "$_link" in
        /*) _me=$_link ;;
        *)  _me="$_dir/$_link" ;;
    esac
done
DOTFILES_ROOT=$(CDPATH= cd -- "$(dirname -- "$_me")" && pwd -P)

DRY_RUN=0
DO_CLEAN=0
for arg in "$@"; do
    case "$arg" in
        --clean)  DO_CLEAN=1 ;;
        --dry-run) DRY_RUN=1 ;;
        *) printf 'unknown option: %s\n' "$arg" ;;
    esac
done

# Every path that install.sh links, in the same order.
TARGETS="
$HOME/.bashrc
$HOME/.bash_profile
$HOME/.bash_logout
$HOME/.gitconfig
$HOME/.local/share/applications/yazi.desktop
$HOME/.config/hyprland.lua
$HOME/.config/quickshell
$HOME/.config/kitty/kitty.conf
$HOME/.config/kitty.conf
$HOME/.config/fish/config.fish
$HOME/.config/nvim
"

removed=0
restored=0
for target in $TARGETS; do
    [ -e "$target" ] || [ -L "$target" ] || { printf 'skip (absent) : %s\n' "$target"; continue; }

    if [ ! -L "$target" ]; then
        printf 'keep (real)   : %s\n' "$target"
        continue
    fi

    link=$(readlink "$target")
    case "$link" in
        "$DOTFILES_ROOT"/*)
            # Managed by us.
            if [ "$DRY_RUN" = 1 ]; then
                printf 'would remove  : %s\n' "$target"
                continue
            fi
            printf 'remove        : %s\n' "$target"
            rm -f -- "$target"
            removed=$((removed + 1))

            # Restore the newest backup for this basename, if any exists.
            # Shell-expanded glob; newest by reversed lexical name (= date).
            # shellcheck disable=SC2012
            newest=$(ls -1t "$DOTFILES_ROOT"/backups/*/"$(basename "$target")" 2>/dev/null | head -n 1)
            if [ -n "$newest" ]; then
                # Only restore into the same absolute location it came from.
                mkdir -p "$(dirname "$target")"
                cp -a -- "$newest" "$target"
                printf 'restore       : %s <- %s\n' "$target" "$newest"
                restored=$((restored + 1))
            fi
            ;;
        *)
            printf 'keep (foreign): %s\n' "$target"
            ;;
    esac
done

if [ "$DO_CLEAN" = 1 ] && [ "$DRY_RUN" = 0 ]; then
    rm -rf -- "$DOTFILES_ROOT/backups"
    printf 'removed backups dir: %s/backups\n' "$DOTFILES_ROOT"
fi

printf '\n'
printf 'removed %s managed link(s), restored %s file(s).\n' "$removed" "$restored"
printf 'Machine-local files (fish_variables, .ssh, caches, ...) were left untouched.\n'