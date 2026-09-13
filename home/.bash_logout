# ~/.bash_logout -- managed by ~/dotfiles.
# Executed by bash for login shells when they exit.

if [ "$BASH_NONINTERACTIVE" != "1" ] && [ -x /usr/bin/clear_console ]; then
    /usr/bin/clear_console -q 2>/dev/null
fi