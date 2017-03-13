# Set some sensible defaults for installed apps

# Copy iTerm2 config file
cp init/com.googlecode.iterm2.plist ~/Library/Preferences

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Copy Atom config file
cp init/config.cson ~/.atom

# Disable swipe controls for Google Chrome
defaults write com.google.Chrome.plist AppleEnableSwipeNavigateWithScrolls -bool FALSE
