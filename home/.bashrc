# ~/.bashrc -- managed by ~/dotfiles (see ~/dotfiles/install.sh).
# This file is only used when you open a bash shell directly
# (fish is the default interactive shell in this setup).

# Source the distribution's global bashrc, if present.
# Fedora provides /etc/bashrc, Arch provides /etc/bash.bashrc.
for geo_rc in /etc/bashrc /etc/bash.bashrc; do
    [ -f "$geo_rc" ] && . "$geo_rc"
done
unset geo_rc

# Keep user-local bin directories on the PATH.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
export PATH

# Load optional per-user bash snippets from ~/.bashrc.d if it exists.
if [ -d "$HOME/.bashrc.d" ]; then
    for rc in "$HOME/.bashrc.d"/*; do
        [ -f "$rc" ] && . "$rc"
    done
    unset rc
fi