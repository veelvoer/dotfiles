# shellcheck shell=sh
# ---------------------------------------------------------------------------
# bootstrap/common.sh
#
# Shared helpers for the dotfiles install/uninstall scripts.
# Sourced by install.sh and uninstall.sh. POSIX sh only.
# ---------------------------------------------------------------------------

# -------- Output helpers ----------------------------------------------------
info()  { printf '\033[1;34m[i]\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[!]\033[0m %s\n' "$1" >&2; }
err()   { printf '\033[1;31m[x]\033[0m %s\n' "$1" >&2; }

# -------- Paths -------------------------------------------------------------
# Location of the repository (…/dotfiles). Works whether called via a
# symlink, from any cwd, or with a relative/absolute script path.
dotfiles_root() {
    _script_path="$1"
    _resolved=""
    # Resolve symlinks so `install.sh` symlinked onto PATH still works.
    while [ -L "$_script_path" ]; do
        _dir=$(dirname "$_script_path")
        _link=$(readlink "$_script_path")
        case "$_link" in
            /*) _script_path="$_link" ;;
            *)  _script_path="$_dir/$_link" ;;
        esac
    done
    _dir=$(CDPATH= cd -- "$(dirname -- "$_script_path")" 2>/dev/null && pwd -P)
    # Link script lives directly in the repo root.
    printf '%s' "$_dir"
}

# -------- Operating-system detection ---------------------------------------
# Sets: DOTFILES_OS (fedora|arch|nixos|unknown), DOTFILES_PKG (dnf|pacman|nix|none)
detect_os() {
    DOTFILES_OS=unknown
    DOTFILES_PKG=none

    if [ -r /etc/os-release ]; then
        # Pops up the OS name; do NOT `export` from here, caller exports.
        _id=""
        _id_like=""
        _pretty=""
        while IFS='=' read -r _key _val; do
            case "$_key" in
                ID) _id=$_val ;;
                ID_LIKE) _id_like=$_val ;;
                PRETTY_NAME) _pretty=$_val ;;
            esac
        done < /etc/os-release
        # Strip quotes.
        _id=${_id#\"}; _id=${_id%\"}
        _id_like=${_id_like#\"}; _id_like=${_id_like%\"}

        printf '%s\n' "$_id $_id_like" | grep -qi 'nixos' && DOTFILES_OS=nixos
        printf '%s\n' "$_id $_id_like" | grep -qi '^arch\|arch\b\|cachyos' && DOTFILES_OS=arch
        printf '%s\n' "$_id" | grep -qi '^fedora' && DOTFILES_OS=fedora
    fi

    case "$DOTFILES_OS" in
        fedora) DOTFILES_PKG=dnf ;;
        arch)   DOTFILES_PKG=pacman ;;
        nixos)  DOTFILES_PKG=nix ;;
    esac
}

# -------- Command checks ----------------------------------------------------
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# -------- Backup ------------------------------------------------------------
# back up an existing, genuinely user-owned target before we replace it with
# a managed symlink. Store inside the repo under backups/ (git-ignored).
# Returns 0 if a backup was made, 1 if nothing to back up.
backup_path() {
    _target="$1"
    [ -e "$_target" ] || [ -L "$_target" ] || return 1
    # Symlinks pointing at our repo are "already managed" - no backup needed.
    if [ -L "$_target" ] && [ "$(readlink "$_target")" = "$DOTFILES_ROOT/$2" ]; then
        return 1
    fi
    _stamp=$(date +%Y%m%d-%H%M%S)
    _backup_dir="$DOTFILES_ROOT/backups/$_stamp"
    mkdir -p "$_backup_dir"
    cp -a -- "$_target" "$_backup_dir/$(basename "$_target")"
    warn "backed up: $_target -> $_backup_dir/$(basename "$_target")"
    return 0
}

# -------- Symlinking --------------------------------------------------------
# link target <- repo-relative-source
# 1. skips if already correctly linked (idempotent)
# 2. backs up any existing user file
# 3. removes stale symlink, then creates a fresh absolute symlink
# 4. returns non-zero when the target exists and is NOT a symlink we manage
link_dotfile() {
    _rel_src="$1"   # path inside the repo, e.g. "config/hypr/hyprland.lua"
    _target="$2"    # absolute destination, e.g. $HOME/.config/hyprland.lua
    _src="$DOTFILES_ROOT/$_rel_src"

    if [ ! -e "$_src" ] && [ ! -L "$_src" ]; then
        err "source missing in repo: $_rel_src"
        return 0
    fi

    mkdir -p "$(dirname "$_target")"

    # Already the managed link? No-op.
    if [ -L "$_target" ]; then
        _cur=$(readlink "$_target")
        if [ "$_cur" = "$_src" ] || [ "$_cur" = "$_rel_src" ]; then
            ok "linked: $_target"
            return 0
        fi
        # Stale or foreign symlink: back it up and replace.
        _stamp=$(date +%Y%m%d-%H%M%S)
        mkdir -p "$DOTFILES_ROOT/backups/$_stamp"
        cp -aP -- "$_target" "$DOTFILES_ROOT/backups/$_stamp/$(basename "$_target")" 2>/dev/null
        warn "replaced foreign link: $_target"
        if [ -z "${DRY_RUN+1}" ] || [ "$DRY_RUN" -ne 1 ]; then
            rm -f -- "$_target"
        fi
    elif [ -e "$_target" ]; then
        if [ -z "${DRY_RUN+1}" ] || [ "$DRY_RUN" -ne 1 ]; then
            backup_path "$_target" "$_rel_src"
            rm -f -- "$_target"   # safe: content is preserved in backups/
        else
            info "would back up and replace existing file: $_target"
        fi
    fi

    if [ "$DRY_RUN" = 1 ]; then
        info "would link: $_target -> $_src"
    else
        ln -s -- "$_src" "$_target"
        ok "linked: $_target -> $_src"
    fi
}

# -------- Enforcement guard -------------------------------------------------
want_dir() {  # create dirs that are needed for links to be created
    if [ "$DRY_RUN" = 1 ]; then
        info "would create dir: $1"
    else
        mkdir -p "$1"
    fi
}