if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Make the opencode CLI available if it has been installed to ~/.opencode/bin.
# This is a per-machine install (not part of this repository).
if test -d "$HOME/.opencode/bin"
    fish_add_path "$HOME/.opencode/bin"
end