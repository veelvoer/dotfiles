set -g fish_greeting ""

# Make the opencode CLI available if it has been installed to ~/.opencode/bin.
# This is a per-machine install (not part of this repository).
if test -d "$HOME/.opencode/bin"
    fish_add_path "$HOME/.opencode/bin"
end

# ---------------------------------------------------------------------------
# Mountain Horizon prompt
# ---------------------------------------------------------------------------
function fish_prompt
    set -l last_status $status

    # Mountain Horizon Palette (Hex Colors)
    set -l bg_pill 12424c
    set -l bg_git 219ba4
    set -l dark_text 0d2c34
    set -l light_text e8f8fa
    set -l bright_teal 3fd0dc
    set -l cyan_glow 2bb1bb
    set -l dim_teal 186a73
    set -l error_red f38ba8

    echo -e "" # Spacer line

    # -----------------------------------------------------------------
    # LINE 1: STATUS PILLS
    # -----------------------------------------------------------------

    # 1. Directory Pill [ 󰉋 ~/path ]
    set_color $bg_pill
    echo -n ""
    set_color -b $bg_pill --bold $bright_teal
    echo -n "󰉋 "
    set_color -b $bg_pill $light_text
    echo -n (prompt_pwd)
    set_color normal
    set_color $bg_pill
    echo -n " "

    # 2. Git Pill (Only inside repos) [  main ]
    if type -q git; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (command git branch --show-current 2>/dev/null)
        test -z "$branch"; and set branch (command git rev-parse --short HEAD 2>/dev/null)

        set_color $bg_git
        echo -n ""
        set_color -b $bg_git --bold $dark_text
        echo -n " "
        set_color -b $bg_git --bold $dark_text
        echo -n "$branch"

        if command git status --porcelain 2>/dev/null | string length -q
            set_color -b $bg_git --bold $light_text
            echo -n " •"
        end

        set_color normal
        set_color $bg_git
        echo -n " "
    end

    # 3. Clock Pill (Inline with Directory) [ 󰥔 14:30 ]
    set_color $bg_pill
    echo -n ""
    set_color -b $bg_pill --bold $cyan_glow
    echo -n "󰥔 "
    set_color -b $bg_pill $light_text
    echo -n (date "+%H:%M")
    set_color normal
    set_color $bg_pill
    echo -n ""

    # -----------------------------------------------------------------
    # LINE 2: PROMPT SYMBOL
    # -----------------------------------------------------------------
    echo ""
    if test $last_status -eq 0
        set_color --bold $bright_teal
        echo -n " ❯ "
    else
        set_color --bold $error_red
        echo -n " ✖ "
    end

    set_color normal
end

# Clear right prompt to prevent secondary line drifting
function fish_right_prompt
end