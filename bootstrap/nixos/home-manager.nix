# dotfiles on NixOS
#
# On NixOS configuration is declared, not mutated — so the imperative
# `install.sh --packages` is intentionally skipped (install.sh still links
# the config files, which works fine). Add the snippet below to your
# home-manager configuration instead.

{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------- packages
  home.packages = with pkgs; [
    # shell & editors
    fish git micro neovim gh
    # terminal
    kitty
    # compositor
    hyprland hyprlock hypridle
    # launcher & wayland tools
    rofi swaybg grim slurp wl-clipboard playerctl brightnessctl
    # file manager
    yazi dolphin
    # bar / shell (quickshell)
    quickshell
    # productivity / dx
    fastfetch zoxide fd fzf bat
    # fonts used by prompt and bar
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # --------------------------------------------------------------- fish as shell
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # nothing machine-specific goes here; see ~/dotfiles/config/fish/config.fish
  '';

  # -------------------------------------------------managed config symlinks
  # Equivalent of `~/dotfiles/install.sh` for the file links. These overlay
  # the store paths with your dotfiles (use `home.file` for dotfiles-style
  # links; `programs.X.configFile` works too).
  home.file = {
    ".bashrc"                 = { source = ~/dotfiles/home/.bashrc; };
    ".bash_profile"           = { source = ~/dotfiles/home/.bash_profile; };
    ".bash_logout"            = { source = ~/dotfiles/home/.bash_logout; };
    ".gitconfig"              = { source = ~/dotfiles/home/.gitconfig; };
    ".config/hyprland.lua"    = { source = ~/dotfiles/config/hypr/hyprland.lua; };
    ".config/quickshell"      = { source = ~/dotfiles/config/quickshell; recursive = true; };
    ".config/kitty/kitty.conf"= { source = ~/dotfiles/config/kitty/kitty.conf; };
    ".config/fish/config.fish"= { source = ~/dotfiles/config/fish/config.fish; };
    ".config/nvim"            = { source = ~/dotfiles/config/nvim; recursive = true; };
  };
}