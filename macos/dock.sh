#!/bin/sh

apps=(
    "Canary Mail"
    "Notion Calendar"
    "Slack"
    "1Password"
    "ChatGPT"

    "Arc"
    "Spotify"
    
    "Figma"

    "Visual Studio Code"
    "Warp"
    "GitHub Desktop"
    "TablePlus"
    "Postman"
)

dockutil --no-restart --remove all

for app in "${apps[@]}"; do
    dockutil --no-restart --add "/Applications/${app}.app"
done;

dockutil --add '' --type spacer --section apps --after "Finder.app"
dockutil --add '' --type spacer --section apps --after "ChatGPT.app"
dockutil --add '' --type spacer --section apps --after "Spotify.app"
dockutil --add '' --type spacer --section apps --after "Figma.app"

killall Dock
