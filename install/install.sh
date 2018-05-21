DOTFILES_DIR=~/dotfiles

# Install Brew with packages & casks
. "$DOTFILES_DIR/install/brew.sh"

# Install nvm, Node, npm, Yarn
. "$DOTFILES_DIR/install/node.sh"

# Install Yarn global packages
. "$DOTFILES_DIR/install/yarn.sh"

# Install Oh My Zsh
. "$DOTFILES_DIR/install/zsh.sh"

# Set up symlinks
. "$DOTFILES_DIR/install/symlinks.sh"

# Set up macOS defaults
. "$DOTFILES_DIR/macos/defaults.sh"

# Set up macOS dock
. "$DOTFILES_DIR/macos/dock.sh"
