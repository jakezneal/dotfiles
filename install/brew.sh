# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew upgrade

brew=(
    composer
    dockutil
    git
    mysql
    openssl
    pnpm
    python3
    starship
    wget
)

# Install packages
for package in "${brew[@]}"; do
    brew install $package
done;

cask=(
    1password
    appcleaner
    arc
    chatgpt
    dbngin
    docker-desktop
    figma
    flux-app
    github
    keka
    logitune
    maccy
    notion-calendar
    postman
    raycast
    rectangle
    slack
    spotify
    tableplus
    visual-studio-code
    warp
    whatsapp
)

# Install cask packages
for package in "${cask[@]}"; do
    brew install --cask --appdir="/Applications" $package
done;
