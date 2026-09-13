# SSH keys — never commit the private key.
#
# Copy the PUBLIC key only if you want it in the repo (safe to share):
#   cp ~/.ssh/id_ed25519.pub secrets.example/id_ed25519.pub
#
# The PRIVATE key MUST remain machine-local at ~/.ssh/id_ed25519
# and is excluded by .gitignore. Recreate on a fresh machine with:
#   ssh-keygen -t ed25519 -C "your-comment"

Observations
============
- Keep `~/.ssh` entirely out of the repo (mode 700, owner only).
- If the private key is ever committed anywhere, rotate it immediately.
- On a fresh machine, restore: mkdir -p ~/.ssh && chmod 700 ~/.ssh
  then place the key and `ssh-add`.