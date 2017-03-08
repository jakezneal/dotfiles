# Install command-line tools using Homebrew

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
sudo xcodebuild -license

# Install Git
brew install git

# Install Node.js - this installs `npm` too, using the recommended installation method
brew install node

# Install Brew Cask for managing other apps
brew install caskroom/cask

# Install Cask versions for beta version of apps :D
brew tap caskroom/versions
