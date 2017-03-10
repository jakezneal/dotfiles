# Core
brew cask install --appdir="/Applications" 1clipboard
brew cask install --appdir="/Applications" 1password
brew cask install --appdir="/Applications" adobe-creative-cloud
brew cask install --appdir="/Applications" adobe-illustrator-cc
brew cask install --appdir="/Applications" adobe-photoshop-cc
brew cask install --appdir="/Applications" alfred
brew cask install --appdir="/Applications" keka
brew cask install --appdir="/Applications" logitech-options
brew cask install --appdir="/Applications" skyfonts

# Browsers
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" google-chrome-canary

# Development apps
brew cask install --appdir="/Applications" atom
brew cask install --appdir="/Applications" docker
brew cask install --appdir="/Applications" filezilla
brew cask install --appdir="/Applications" ghostlab
brew cask install --appdir="/Applications" imageoptim
brew cask install --appdir="/Applications" iterm2
brew cask install --appdir="/Applications" sequel-pro
brew cask install --appdir="/Applications" tower

# Additional apps
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" post-haste
brew cask install --appdir="/Applications" skype
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" spotify
brew cask install --appdir="/Applications" transmission
brew cask install --appdir="/Applications" vlc
brew cask install --appdir="/Applications" wd-my-cloud

# Cleanup
brew cleanup --force

rm -rf /Library/Caches/Homebrew/*
