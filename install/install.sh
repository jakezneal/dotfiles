DOTFILES_DIR=~/dotfiles

# Install Brew with packages & casks
. "$DOTFILES_DIR/install/brew.sh"

# Set up symlinks
. "$DOTFILES_DIR/install/symlinks.sh"

# Set up macOS defaults
. "$DOTFILES_DIR/macos/defaults.sh" "$@"

# Set up macOS dock
. "$DOTFILES_DIR/macos/dock.sh"
