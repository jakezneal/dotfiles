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

dockutil --add '' --type spacer --section apps --after "Finder"
dockutil --add '' --type spacer --section apps --after "ChatGPT"
dockutil --add '' --type spacer --section apps --after "Spotify"
dockutil --add '' --type spacer --section apps --after "Figma"
dockutil --add '' --type spacer --section apps --after "Postman"

killall Dock
