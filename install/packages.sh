#!/usr/bin/env bash
# Package definitions

# Required formulae
REQUIRED_FORMULAE=(
    dockutil
)

# Selectable formulae
FORMULAE=(
    composer
    git
    mysql
    openssl
    pnpm
    python3
    starship
    wget
)

# Selectable casks
CASKS=(
    1password
    appcleaner
    arc
    chatgpt
    dbngin
    figma
    flux-app
    github
    keka
    logitune
    maccy
    notion-calendar
    raycast
    rectangle
    spotify
    tableplus
    visual-studio-code
    warp
    whatsapp
)

###############################################################################
# Cask group options
###############################################################################
CASK_GROUP_NAMES=(
    CONTAINER
    COMMUNICATION
    API
)

# Container
CASK_GROUP_CONTAINER_LABEL="Container Runtime"
CASK_GROUP_CONTAINER_OPTIONS=(
    "docker-desktop:Docker Desktop"
    "orbstack:OrbStack"
)

# Communication
CASK_GROUP_COMMUNICATION_LABEL="Communication App"
CASK_GROUP_COMMUNICATION_OPTIONS=(
    "slack:Slack"
    "microsoft-teams:Microsoft Teams"
)

# API Tools
CASK_GROUP_API_LABEL="API Development Tool"
CASK_GROUP_API_OPTIONS=(
    "postman:Postman"
    "bruno:Bruno"
)
