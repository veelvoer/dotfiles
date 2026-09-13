# ~/.bash_profile -- managed by ~/dotfiles (see ~/dotfiles/install.sh).
# Executed by bash for login shells. fish is the default interactive
# shell in this setup, so this file exists mainly for recovery / SSH.

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# User-specific environment and startup programs.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
export PATH