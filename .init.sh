# Set some sensible defaults for installed apps

# Copy iTerm2 config file
cp init/com.googlecode.iterm2.plist ~/Library/Preferences

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Install the Solarized Dark theme for iTerm
open "${HOME}/iTerm2-Color-Schemes/schemes/Solarized Dark.itermcolors"

# Copy Atom config file
cp init/config.cson ~/.atom
