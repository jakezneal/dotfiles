# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap caskroom/cask
brew tap caskroom/fonts
brew tap caskroom/drivers

brew update
brew upgrade

brew=(
    ack
    composer
    dockutil
    emojify
    git
    graphicsmagick
    mysql
    openssl
    python3
    webkit2png
    wget
    wifi-password
)

# Install packages
for package in "${brew[@]}"; do
    brew install $package
done;

cask=(
    1clipboard
    1password
    adobe-creative-cloud
    alfred
    appcleaner
    astro
    balsamiq-mockups
    cyberduck
    dropbox
    firefox
    flux
    google-chrome
    google-chrome-canary
    imageoptim
    iterm2
    karabiner-elements
    keka
    logitech-options
    macdown
    mamp
    muzzle
    quitter
    rocket
    slack
    spectacle
    spotify
    tableplus
    tower
    visual-studio-code
)

# Install cask packages
for package in "${cask[@]}"; do
    brew cask install --appdir="/Applications" $package
done;

quicklook=(
    qlcolorcode
    qlimagesize
    qlmarkdown
    qlstephen
    qlvideo
    quicklook-json
    quicklook-csv
    webpquicklook
)

# Install QL plugins
for package in "${quicklook[@]}"; do
    brew cask install $package
done;

fonts=(
    inconsolata
    fira-code
)

# Install fonts
for font in "${fonts[@]}"; do
    brew cask instal font-$font
done;
